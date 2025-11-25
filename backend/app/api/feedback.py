"""
User Feedback API
Collects user feedback on generated content for continuous improvement
"""
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, List
from datetime import datetime
import logging

from app.dependencies import get_current_user
from firebase_admin import firestore

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/feedback", tags=["Feedback"])

# Initialize Firestore client
db = firestore.client()


class FeedbackRequest(BaseModel):
    """User feedback on generated content"""
    generation_id: str = Field(..., description="ID of the generation")
    content_type: str = Field(..., description="Type of content (blog, social, etc.)")
    rating: int = Field(..., ge=1, le=5, description="Rating 1-5 stars")
    feedback_text: Optional[str] = Field(None, description="Optional feedback text")
    issues: Optional[List[str]] = Field(default=None, description="List of issues (grammar, tone, accuracy, etc.)")
    helpful: Optional[bool] = Field(None, description="Was the content helpful?")


class RegenerationRequest(BaseModel):
    """Request to regenerate content with specific improvements"""
    generation_id: str = Field(..., description="ID of original generation")
    improvement_notes: str = Field(..., description="What needs to be improved")
    content_type: str


@router.post("/submit")
async def submit_feedback(
    feedback: FeedbackRequest,
    current_user: dict = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Submit user feedback on generated content
    
    This feedback helps improve AI model selection and quality thresholds
    """
    try:
        user_id = current_user.get('uid')
        
        # Store feedback in Firestore
        feedback_doc = {
            'user_id': user_id,
            'generation_id': feedback.generation_id,
            'content_type': feedback.content_type,
            'rating': feedback.rating,
            'feedback_text': feedback.feedback_text,
            'issues': feedback.issues or [],
            'helpful': feedback.helpful,
            'timestamp': datetime.now(),
            'user_plan': current_user.get('subscriptionPlan', 'free')
        }
        
        doc_ref = db.collection('user_feedback').add(feedback_doc)
        
        logger.info(f"✅ Feedback submitted: {feedback.rating}/5 stars for {feedback.content_type}")
        
        # Update generation record with feedback
        try:
            gen_ref = db.collection('generations').document(feedback.generation_id)
            gen_ref.update({
                'user_rating': feedback.rating,
                'user_feedback': feedback.feedback_text,
                'feedback_timestamp': datetime.now()
            })
        except Exception as e:
            logger.warning(f"Could not update generation record: {e}")
        
        return {
            "success": True,
            "message": "Feedback submitted successfully",
            "feedback_id": doc_ref[1].id
        }
        
    except Exception as e:
        logger.error(f"Error submitting feedback: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/stats")
async def get_feedback_stats(
    content_type: Optional[str] = None,
    current_user: dict = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Get feedback statistics
    
    Admin users see all stats, regular users see only their own
    """
    try:
        user_id = current_user.get('uid')
        user_tier = current_user.get('subscriptionPlan', 'free')
        
        # Query feedback
        feedback_collection = db.collection('user_feedback')
        
        if user_tier in ['admin', 'enterprise']:
            # Admin sees all feedback
            query = feedback_collection
        else:
            # Regular users see only their feedback
            query = feedback_collection.where('user_id', '==', user_id)
        
        if content_type:
            query = query.where('content_type', '==', content_type)
        
        docs = query.limit(1000).stream()
        
        # Aggregate statistics
        total_feedback = 0
        rating_sum = 0
        rating_counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}
        helpful_count = 0
        helpful_total = 0
        issue_counts = {}
        
        for doc in docs:
            data = doc.to_dict()
            total_feedback += 1
            
            rating = data.get('rating', 0)
            rating_sum += rating
            rating_counts[rating] = rating_counts.get(rating, 0) + 1
            
            if data.get('helpful') is not None:
                helpful_total += 1
                if data.get('helpful'):
                    helpful_count += 1
            
            for issue in data.get('issues', []):
                issue_counts[issue] = issue_counts.get(issue, 0) + 1
        
        avg_rating = rating_sum / total_feedback if total_feedback > 0 else 0
        helpful_rate = helpful_count / helpful_total if helpful_total > 0 else 0
        
        return {
            "success": True,
            "data": {
                "total_feedback": total_feedback,
                "average_rating": round(avg_rating, 2),
                "rating_distribution": rating_counts,
                "helpful_rate": round(helpful_rate * 100, 1),
                "common_issues": dict(sorted(issue_counts.items(), key=lambda x: x[1], reverse=True)[:5]),
                "satisfaction_level": _get_satisfaction_level(avg_rating)
            }
        }
        
    except Exception as e:
        logger.error(f"Error fetching feedback stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/request-regeneration")
async def request_regeneration(
    request: RegenerationRequest,
    current_user: dict = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Request content regeneration with improvements
    
    Stores regeneration request for tracking improvement needs
    """
    try:
        user_id = current_user.get('uid')
        
        # Store regeneration request
        regen_doc = {
            'user_id': user_id,
            'generation_id': request.generation_id,
            'content_type': request.content_type,
            'improvement_notes': request.improvement_notes,
            'timestamp': datetime.now(),
            'status': 'pending'
        }
        
        doc_ref = db.collection('regeneration_requests').add(regen_doc)
        
        logger.info(f"📝 Regeneration requested for {request.content_type}: {request.improvement_notes}")
        
        return {
            "success": True,
            "message": "Regeneration request submitted. The content will be regenerated shortly.",
            "request_id": doc_ref[1].id
        }
        
    except Exception as e:
        logger.error(f"Error submitting regeneration request: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/improvement-insights")
async def get_improvement_insights(
    current_user: dict = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Get insights on what needs improvement based on user feedback
    
    Admin only - helps identify quality issues
    """
    try:
        user_tier = current_user.get('subscriptionPlan', 'free')
        
        if user_tier not in ['admin', 'enterprise']:
            raise HTTPException(status_code=403, detail="Admin access required")
        
        # Query low-rated content
        feedback_collection = db.collection('user_feedback')
        low_rated = feedback_collection.where('rating', '<=', 2).limit(100).stream()
        
        # Analyze patterns
        content_type_issues = {}
        common_issues = {}
        model_performance = {}
        
        for doc in low_rated:
            data = doc.to_dict()
            content_type = data.get('content_type', 'unknown')
            
            # Track by content type
            if content_type not in content_type_issues:
                content_type_issues[content_type] = {'count': 0, 'avg_rating': 0, 'total_rating': 0}
            content_type_issues[content_type]['count'] += 1
            content_type_issues[content_type]['total_rating'] += data.get('rating', 0)
            
            # Track issues
            for issue in data.get('issues', []):
                common_issues[issue] = common_issues.get(issue, 0) + 1
        
        # Calculate averages
        for ct in content_type_issues:
            count = content_type_issues[ct]['count']
            total = content_type_issues[ct]['total_rating']
            content_type_issues[ct]['avg_rating'] = round(total / count, 2) if count > 0 else 0
        
        insights = []
        
        # Generate insights
        if 'blog' in content_type_issues and content_type_issues['blog']['count'] > 5:
            insights.append(f"⚠️ Blog posts need improvement ({content_type_issues['blog']['count']} low ratings)")
        
        if 'grammar' in common_issues and common_issues['grammar'] > 10:
            insights.append(f"✏️ Grammar issues reported {common_issues['grammar']} times")
        
        if 'tone' in common_issues and common_issues['tone'] > 10:
            insights.append(f"🎭 Tone issues reported {common_issues['tone']} times")
        
        return {
            "success": True,
            "data": {
                "content_type_performance": content_type_issues,
                "most_common_issues": dict(sorted(common_issues.items(), key=lambda x: x[1], reverse=True)),
                "insights": insights,
                "recommendations": _generate_recommendations(content_type_issues, common_issues)
            }
        }
        
    except Exception as e:
        logger.error(f"Error generating improvement insights: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# Helper functions

def _get_satisfaction_level(avg_rating: float) -> str:
    """Get satisfaction level from average rating"""
    if avg_rating >= 4.5:
        return "Excellent"
    elif avg_rating >= 4.0:
        return "Very Good"
    elif avg_rating >= 3.5:
        return "Good"
    elif avg_rating >= 3.0:
        return "Fair"
    else:
        return "Needs Improvement"


def _generate_recommendations(content_type_issues: Dict, common_issues: Dict) -> List[str]:
    """Generate improvement recommendations"""
    recommendations = []
    
    # Check for grammar issues
    if common_issues.get('grammar', 0) > 10:
        recommendations.append("Consider integrating grammar checking API for all content")
    
    # Check for tone issues
    if common_issues.get('tone', 0) > 10:
        recommendations.append("Review tone adaptation logic for different content types")
    
    # Check for accuracy issues
    if common_issues.get('accuracy', 0) > 5:
        recommendations.append("Implement fact-checking for claims and statistics")
    
    # Check content type specific issues
    for ct, data in content_type_issues.items():
        if data['count'] > 10 and data['avg_rating'] < 2.5:
            recommendations.append(f"Review {ct} generation prompts and quality thresholds")
    
    if not recommendations:
        recommendations.append("✅ No critical issues identified. Continue monitoring.")
    
    return recommendations
