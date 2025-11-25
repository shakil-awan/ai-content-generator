"""
Firebase Service - User Management & Firestore Operations
Handles all database interactions with Firebase Firestore

ARCHITECTURE PATTERN:
1. Use constants from app.constants instead of hardcoding collection names
2. Accept Pydantic models as input (converted to dict for Firestore)
3. Return Pydantic models as output (validated data with type safety)
4. Use type hints for all methods
5. Handle errors with proper logging and exceptions

Example Usage:
    from app.schemas.user import UserCreate
    from app.constants import Collections
    
    user_data = UserCreate(email="test@example.com", password="secure123")
    result = await firebase_service.create_user(user_data.model_dump())
"""
from typing import Optional, Dict, Any, List
from datetime import datetime, timezone
import firebase_admin
from firebase_admin import credentials, firestore, auth as firebase_auth
from app.config import settings
from app.constants import Collections, SubscriptionPlan, SubscriptionStatus
import logging

logger = logging.getLogger(__name__)

class FirebaseService:
    _instance: Optional['FirebaseService'] = None
    _initialized: bool = False
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        if not self._initialized:
            self._initialize_firebase()
            self.db = firestore.client()
            FirebaseService._initialized = True
    
    def _initialize_firebase(self):
        """Initialize Firebase Admin SDK"""
        if not firebase_admin._apps:
            if not settings.FIREBASE_PRIVATE_KEY_PATH:
                raise ValueError("FIREBASE_PRIVATE_KEY_PATH not configured in .env file")
            
            cred = credentials.Certificate(settings.FIREBASE_PRIVATE_KEY_PATH)
            firebase_admin.initialize_app(cred, {
                'storageBucket': settings.FIREBASE_STORAGE_BUCKET.replace('gs://', '')
            })
            logger.info("Firebase initialized successfully")
    
    # ==================== USER OPERATIONS ====================
    
    async def create_user(self, user_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Create new user in Firestore - Complete schema from blueprint
        
        Args:
            user_data: Dict with 'uid', 'email', optional 'displayName', 'profileImage'
        
        Returns:
            Complete user document with all fields from blueprint
        """
        try:
            user_ref = self.db.collection(Collections.USERS).document(user_data['uid'])
            
            user_doc = {
                'email': user_data['email'],
                'displayName': user_data.get('displayName', ''),
                'profileImage': user_data.get('profileImage', ''),
                'password': user_data.get('password'),  # Store hashed password
                'provider': user_data.get('provider', 'email'),  # email or google
                'createdAt': firestore.SERVER_TIMESTAMP,
                'updatedAt': firestore.SERVER_TIMESTAMP,
                'subscription': {
                    'plan': SubscriptionPlan.FREE,
                    'status': SubscriptionStatus.ACTIVE,
                    'currentPeriodStart': datetime.now(timezone.utc),
                    'currentPeriodEnd': None,
                    'stripeSubscriptionId': None,
                    'stripeCustomerId': None,
                    'cancelledAt': None
                },
                'usageThisMonth': {
                    'generations': 0,
                    'limit': 5,  # Free tier limit (updated from blueprint)
                    'resetDate': self._get_next_month_start(),
                    'humanizations': 0,  # Track AI humanizations separately
                    'humanizationsLimit': 3,  # Free tier humanization limit
                    'socialGraphics': 0,  # Track social graphics separately
                    'socialGraphicsLimit': 5  # Free tier graphics limit
                },
                'brandVoice': {
                    'isConfigured': False,
                    'tone': None,
                    'vocabulary': None,
                    'samples': [],
                    'customParameters': {},
                    'trainedAt': None
                },
                'settings': {
                    'defaultContentType': 'blog',
                    'defaultTone': 'professional',
                    'defaultLanguage': 'english',  # Multilingual support
                    'autoFactCheck': True,
                    'emailNotifications': True,
                    'theme': 'light',
                    'primaryUseCase': None  # Will be set during onboarding
                },
                'team': {
                    'role': 'owner',
                    'invitedMembers': []
                },
                'onboarding': {
                    'completed': False,
                    'currentStep': 0,
                    'completedAt': None
                },
                'allTimeStats': {
                    'totalGenerations': 0,
                    'totalHumanizations': 0,
                    'totalGraphics': 0,
                    'averageQualityScore': 0,
                    'favoriteCount': 0
                },
                'account_status': 'active',  # active | pending_deletion | deleted
                'deletion_requested_at': None,
                'deletion_scheduled_for': None,
                'deletion_reason': None
            }
            
            user_ref.set(user_doc)
            logger.info(f"User created: {user_data['uid']}")
            
            # Fetch the document to get the actual timestamps
            created_doc = user_ref.get()
            if created_doc.exists:
                return {'uid': user_data['uid'], **created_doc.to_dict()}
            else:
                # Fallback if document doesn't exist (shouldn't happen)
                return {'uid': user_data['uid'], **user_doc}
        except Exception as e:
            logger.error(f"Error creating user: {e}")
            raise
    
    async def get_user(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Get user by ID"""
        try:
            user_ref = self.db.collection(Collections.USERS).document(user_id)
            user_doc = user_ref.get()
            
            if user_doc.exists:
                return {'uid': user_id, **user_doc.to_dict()}
            return None
        except Exception as e:
            logger.error(f"Error getting user {user_id}: {e}")
            raise
    
    async def get_user_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        """Get user by email"""
        try:
            users_ref = self.db.collection(Collections.USERS)
            query = users_ref.where('email', '==', email).limit(1)
            docs = query.stream()
            
            for doc in docs:
                return {'uid': doc.id, **doc.to_dict()}
            return None
        except Exception as e:
            logger.error(f"Error getting user by email {email}: {e}")
            raise
    
    async def update_user(self, user_id: str, update_data: Dict[str, Any]) -> bool:
        """Update user document"""
        try:
            user_ref = self.db.collection(Collections.USERS).document(user_id)
            update_data['updatedAt'] = firestore.SERVER_TIMESTAMP
            user_ref.update(update_data)
            logger.info(f"User updated: {user_id}")
            return True
        except Exception as e:
            logger.error(f"Error updating user {user_id}: {e}")
            raise
    
    async def increment_usage(self, user_id: str) -> Dict[str, Any]:
        """
        Increment user's generation count - BOTH monthly and lifetime stats
        
        CRITICAL: This is REAL data tracking, not mock data!
        - usageThisMonth.generations++ (tracks monthly limit)
        - allTimeStats.totalGenerations++ (lifetime counter)
        
        Returns updated usage statistics
        """
        try:
            user_ref = self.db.collection(Collections.USERS).document(user_id)
            user_ref.update({
                'usageThisMonth.generations': firestore.Increment(1),
                'allTimeStats.totalGenerations': firestore.Increment(1),
                'updatedAt': firestore.SERVER_TIMESTAMP
            })
            
            user_doc = user_ref.get()
            return user_doc.to_dict()['usageThisMonth']
        except Exception as e:
            logger.error(f"Error incrementing usage for {user_id}: {e}")
            raise
    
    async def check_usage_limit(self, user_id: str) -> bool:
        """Check if user has reached their generation limit"""
        try:
            user = await self.get_user(user_id)
            if not user:
                return False
            
            usage = user['usageThisMonth']
            return usage['generations'] < usage['limit']
        except Exception as e:
            logger.error(f"Error checking usage limit for {user_id}: {e}")
            raise
    
    async def reset_monthly_usage(self, user_id: str, new_limit: int):
        """Reset user's monthly usage counter"""
        try:
            user_ref = self.db.collection(Collections.USERS).document(user_id)
            user_ref.update({
                'usageThisMonth.generations': 0,
                'usageThisMonth.resetDate': self._get_next_month_start(),
                'updatedAt': firestore.SERVER_TIMESTAMP
            })
            logger.info(f"Usage reset for user: {user_id}")
        except Exception as e:
            logger.error(f"Error resetting usage for {user_id}: {e}")
            raise
    
    # ==================== GENERATION OPERATIONS ====================
    
    async def save_generation(self, generation_data: Dict[str, Any]) -> str:
        """Save content generation to Firestore - Complete schema from blueprint"""
        try:
            gen_ref = self.db.collection(Collections.GENERATIONS).document()
            
            generation_doc = {
                'userId': generation_data['userId'],
                'contentType': generation_data['contentType'],
                'userInput': generation_data['userInput'],
                'output': generation_data['output'],
                'settings': {
                    'tone': generation_data.get('settings', {}).get('tone', 'professional'),
                    'language': generation_data.get('settings', {}).get('language', 'english'),
                    'length': generation_data.get('settings', {}).get('length', 0),
                    'customSettings': generation_data.get('settings', {}).get('customSettings', {})
                },
                'qualityMetrics': {
                    'readabilityScore': generation_data.get('qualityMetrics', {}).get('readabilityScore', 0),
                    'originality': generation_data.get('qualityMetrics', {}).get('originality', 0),
                    'grammarScore': generation_data.get('qualityMetrics', {}).get('grammarScore', 0),
                    'factCheckScore': generation_data.get('qualityMetrics', {}).get('factCheckScore', 0),
                    'aiDetectionScore': generation_data.get('qualityMetrics', {}).get('aiDetectionScore', 0),
                    'overallQuality': generation_data.get('qualityMetrics', {}).get('overallQuality', 0)
                },
                'factCheckResults': {
                    'checked': generation_data.get('factCheckResults', {}).get('checked', False),
                    'claims': generation_data.get('factCheckResults', {}).get('claims', []),
                    'verificationTime': generation_data.get('factCheckResults', {}).get('verificationTime', 0)
                },
                'humanization': {
                    'applied': generation_data.get('humanization', {}).get('applied', False),
                    'level': generation_data.get('humanization', {}).get('level', None),
                    'beforeScore': generation_data.get('humanization', {}).get('beforeScore', 0),
                    'afterScore': generation_data.get('humanization', {}).get('afterScore', 0),
                    'detectionAPI': generation_data.get('humanization', {}).get('detectionAPI', None),
                    'processingTime': generation_data.get('humanization', {}).get('processingTime', 0)
                },
                'isContentRefresh': generation_data.get('isContentRefresh', False),
                'originalContentId': generation_data.get('originalContentId', None),
                'videoScriptSettings': generation_data.get('videoScriptSettings', None) if generation_data['contentType'] == 'videoScript' else None,
                'userRating': None,
                'regenerationCount': 0,
                'tokensUsed': generation_data.get('tokensUsed', 0),
                'generationTime': generation_data.get('generationTime', 0),
                'modelUsed': generation_data.get('modelUsed', 'gpt-4o-mini'),
                'createdAt': firestore.SERVER_TIMESTAMP,
                'updatedAt': firestore.SERVER_TIMESTAMP,
                'isFavorite': False,
                'isArchived': False,
                'tags': generation_data.get('tags', []),
                'exportedTo': []
            }
            
            gen_ref.set(generation_doc)
            logger.info(f"Generation saved: {gen_ref.id}")
            
            return gen_ref.id
        except Exception as e:
            logger.error(f"Error saving generation: {e}")
            raise
    
    async def get_generation_by_id(self, generation_id: str) -> Optional[Dict[str, Any]]:
        """
        Get a generation document by ID
        
        Args:
            generation_id: The generation document ID
            
        Returns:
            Generation document data or None if not found
        """
        try:
            doc_ref = self.db.collection(Collections.GENERATIONS).document(generation_id)
            doc = doc_ref.get()
            
            if doc.exists:
                data = doc.to_dict()
                data['id'] = doc.id
                return data
            return None
        except Exception as e:
            logger.error(f"Error getting generation {generation_id}: {e}")
            raise
    
    async def get_user_generations(
        self, 
        user_id: str, 
        limit: int = 20,
        content_type: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """Get user's generation history"""
        try:
            query = self.db.collection(Collections.GENERATIONS).where('userId', '==', user_id)
            
            if content_type:
                query = query.where('contentType', '==', content_type)
            
            query = query.order_by('createdAt', direction=firestore.Query.DESCENDING).limit(limit)
            docs = query.stream()
            
            generations = []
            for doc in docs:
                generations.append({'id': doc.id, **doc.to_dict()})
            
            return generations
        except Exception as e:
            logger.error(f"Error getting generations for {user_id}: {e}")
            raise
    
    async def get_generation_by_id(self, generation_id: str) -> Optional[Dict[str, Any]]:
        """Get a single generation by ID"""
        try:
            gen_ref = self.db.collection(Collections.GENERATIONS).document(generation_id)
            doc = gen_ref.get()
            
            if doc.exists:
                return {'id': doc.id, **doc.to_dict()}
            return None
        except Exception as e:
            logger.error(f"Error getting generation {generation_id}: {e}")
            raise
    
    async def update_generation(self, generation_id: str, updates: Dict[str, Any]):
        """Update generation document with new data"""
        try:
            gen_ref = self.db.collection(Collections.GENERATIONS).document(generation_id)
            updates['updatedAt'] = firestore.SERVER_TIMESTAMP
            gen_ref.update(updates)
            logger.info(f"Generation updated: {generation_id}")
        except Exception as e:
            logger.error(f"Error updating generation {generation_id}: {e}")
            raise
    
    async def update_generation_rating(self, generation_id: str, rating: int, feedback: str = ""):
        """Update generation with user rating"""
        try:
            gen_ref = self.db.collection(Collections.GENERATIONS).document(generation_id)
            gen_ref.update({
                'userRating': {
                    'rating': rating,
                    'feedback': feedback,
                    'ratedAt': firestore.SERVER_TIMESTAMP
                },
                'updatedAt': firestore.SERVER_TIMESTAMP
            })
            logger.info(f"Generation rated: {generation_id} - {rating} stars")
        except Exception as e:
            logger.error(f"Error updating rating for {generation_id}: {e}")
            raise
    
    # ==================== SUBSCRIPTION OPERATIONS ====================
    
    async def update_subscription(self, user_id: str, subscription_data: Dict[str, Any]):
        """Update user subscription details"""
        try:
            user_ref = self.db.collection(Collections.USERS).document(user_id)
            
            update_dict = {
                'subscription': subscription_data,
                'updatedAt': firestore.SERVER_TIMESTAMP
            }
            
            user_ref.update(update_dict)
            logger.info(f"Subscription updated for user: {user_id}")
        except Exception as e:
            logger.error(f"Error updating subscription for {user_id}: {e}")
            raise
    
    async def update_usage_limits(self, user_id: str, limits: Dict[str, int]):
        """
        Update user's usage limits based on subscription tier
        
        Args:
            user_id: User's Firebase UID
            limits: Dict with 'generations', 'humanizations', 'socialGraphics'
        """
        try:
            user_ref = self.db.collection(Collections.USERS).document(user_id)
            
            update_dict = {
                'usageThisMonth.limit': limits.get('generations', 5),
                'usageThisMonth.humanizationsLimit': limits.get('humanizations', 3),
                'usageThisMonth.socialGraphicsLimit': limits.get('socialGraphics', 5),
                'updatedAt': firestore.SERVER_TIMESTAMP
            }
            
            user_ref.update(update_dict)
            logger.info(f"Usage limits updated for user {user_id}: {limits}")
        except Exception as e:
            logger.error(f"Error updating usage limits for {user_id}: {e}")
            raise
    
    # ==================== HELPER METHODS ====================
    
    def _get_next_month_start(self) -> datetime:
        """Get start of next month"""
        now = datetime.now(timezone.utc)
        if now.month == 12:
            return datetime(now.year + 1, 1, 1, tzinfo=timezone.utc)
        return datetime(now.year, now.month + 1, 1, tzinfo=timezone.utc)
    
    async def verify_firebase_token(self, id_token: str) -> Optional[Dict[str, Any]]:
        """Verify Firebase ID token"""
        try:
            decoded_token = firebase_auth.verify_id_token(id_token)
            return decoded_token
        except Exception as e:
            logger.error(f"Token verification failed: {e}")
            return None
    
    # ==================== HUMANIZATION TRACKING ====================
    
    async def increment_humanization_usage(self, user_id: str) -> Dict[str, Any]:
        """Increment user's humanization count"""
        try:
            user_ref = self.db.collection(Collections.USERS).document(user_id)
            user_ref.update({
                'usageThisMonth.humanizations': firestore.Increment(1),
                'allTimeStats.totalHumanizations': firestore.Increment(1),
                'updatedAt': firestore.SERVER_TIMESTAMP
            })
            
            user_doc = user_ref.get()
            return user_doc.to_dict()['usageThisMonth']
        except Exception as e:
            logger.error(f"Error incrementing humanization for {user_id}: {e}")
            raise
    
    async def check_humanization_limit(self, user_id: str) -> bool:
        """Check if user has remaining humanizations"""
        try:
            user = await self.get_user(user_id)
            if not user:
                return False
            
            usage = user['usageThisMonth']
            return usage['humanizations'] < usage['humanizationsLimit']
        except Exception as e:
            logger.error(f"Error checking humanization limit for {user_id}: {e}")
            raise
    
    # ==================== ONBOARDING ====================
    
    async def update_onboarding_step(self, user_id: str, step: int):
        """Update user's onboarding progress"""
        try:
            user_ref = self.db.collection(Collections.USERS).document(user_id)
            update_data = {
                'onboarding.currentStep': step,
                'updatedAt': firestore.SERVER_TIMESTAMP
            }
            
            if step >= 6:  # Onboarding complete (6 steps total)
                update_data['onboarding.completed'] = True
                update_data['onboarding.completedAt'] = firestore.SERVER_TIMESTAMP
            
            user_ref.update(update_data)
            logger.info(f"Onboarding step updated for user: {user_id} - Step {step}")
        except Exception as e:
            logger.error(f"Error updating onboarding for {user_id}: {e}")
            raise
    
    async def set_primary_use_case(self, user_id: str, use_case: str):
        """Set user's primary use case during onboarding"""
        try:
            user_ref = self.db.collection(Collections.USERS).document(user_id)
            user_ref.update({
                'settings.primaryUseCase': use_case,
                'updatedAt': firestore.SERVER_TIMESTAMP
            })
            logger.info(f"Primary use case set for user: {user_id} - {use_case}")
        except Exception as e:
            logger.error(f"Error setting use case for {user_id}: {e}")
            raise
    
    # ==================== BRAND VOICE ====================
    
    async def train_brand_voice(self, user_id: str, voice_data: Dict[str, Any]):
        """Save trained brand voice for user"""
        try:
            user_ref = self.db.collection(Collections.USERS).document(user_id)
            user_ref.update({
                'brandVoice': {
                    'isConfigured': True,
                    'tone': voice_data.get('tone'),
                    'vocabulary': voice_data.get('vocabulary'),
                    'samples': voice_data.get('samples', []),
                    'customParameters': voice_data.get('customParameters', {}),
                    'trainedAt': firestore.SERVER_TIMESTAMP
                },
                'updatedAt': firestore.SERVER_TIMESTAMP
            })
            logger.info(f"Brand voice trained for user: {user_id}")
        except Exception as e:
            logger.error(f"Error training brand voice for {user_id}: {e}")
            raise
    
    # ==================== CONTENT REFRESH ====================
    
    async def mark_content_for_refresh(self, generation_id: str, issues: List[str]):
        """Mark old content with outdated data that needs refreshing"""
        try:
            gen_ref = self.db.collection(Collections.GENERATIONS).document(generation_id)
            gen_ref.update({
                'needsRefresh': True,
                'refreshIssues': issues,
                'lastRefreshCheck': firestore.SERVER_TIMESTAMP,
                'updatedAt': firestore.SERVER_TIMESTAMP
            })
            logger.info(f"Content marked for refresh: {generation_id}")
        except Exception as e:
            logger.error(f"Error marking content for refresh {generation_id}: {e}")
            raise
    
    # ==================== TEAM MANAGEMENT ====================
    
    async def invite_team_member(self, user_id: str, email: str, role: str):
        """Invite team member to collaborate"""
        try:
            user_ref = self.db.collection(Collections.USERS).document(user_id)
            user_ref.update({
                'team.invitedMembers': firestore.ArrayUnion([{
                    'email': email,
                    'role': role,
                    'status': 'pending',
                    'invitedAt': firestore.SERVER_TIMESTAMP
                }]),
                'updatedAt': firestore.SERVER_TIMESTAMP
            })
            logger.info(f"Team member invited: {email} to user {user_id}")
        except Exception as e:
            logger.error(f"Error inviting team member for {user_id}: {e}")
            raise
            return None

# Singleton instance
firebase_service = FirebaseService()
