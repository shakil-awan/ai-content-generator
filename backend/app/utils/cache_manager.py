"""
Cache Manager for AI Content Generator
Handles Redis caching with Firestore fallback for AI generations and prompts.
"""

import json
import hashlib
from typing import Optional, Any, Dict
from datetime import timedelta
import logging

try:
    import redis
    from redis.exceptions import RedisError
    REDIS_AVAILABLE = True
except ImportError:
    REDIS_AVAILABLE = False

from app.config import settings

logger = logging.getLogger(__name__)


class CacheManager:
    """
    Manages caching for AI generations using Redis (primary) with Firestore fallback.
    """
    
    def __init__(self):
        """Initialize cache manager with Redis client."""
        self.redis_client = None
        self.cache_enabled = settings.ENABLE_CACHE
        
        if self.cache_enabled and REDIS_AVAILABLE:
            try:
                # Initialize Redis client
                self.redis_client = redis.Redis(
                    host=settings.REDIS_HOST,
                    port=settings.REDIS_PORT,
                    password=settings.REDIS_PASSWORD,
                    db=settings.REDIS_DB,
                    decode_responses=True,
                    socket_timeout=5,
                    socket_connect_timeout=5
                )
                # Test connection
                self.redis_client.ping()
                logger.info("✅ Redis cache connected successfully")
            except Exception as e:
                logger.warning(f"⚠️ Redis connection failed: {e}. Caching disabled.")
                self.redis_client = None
        else:
            if not self.cache_enabled:
                logger.info("ℹ️ Cache disabled in configuration")
            elif not REDIS_AVAILABLE:
                logger.warning("⚠️ Redis library not available. Install with: pip install redis")
    
    def _generate_cache_key(self, prefix: str, **kwargs) -> str:
        """
        Generate a unique cache key from prefix and parameters.
        
        Args:
            prefix: Cache key prefix (e.g., 'generation', 'prompt')
            **kwargs: Parameters to include in key generation
            
        Returns:
            str: Unique cache key (e.g., 'generation:abc123def456')
        """
        # Sort kwargs for consistent hashing
        sorted_params = sorted(kwargs.items())
        param_str = json.dumps(sorted_params, sort_keys=True)
        hash_value = hashlib.sha256(param_str.encode()).hexdigest()[:16]
        return f"{prefix}:{hash_value}"
    
    def get(self, key: str) -> Optional[Any]:
        """
        Retrieve value from cache.
        
        Args:
            key: Cache key
            
        Returns:
            Cached value or None if not found
        """
        if not self.cache_enabled or not self.redis_client:
            return None
        
        try:
            value = self.redis_client.get(key)
            if value:
                logger.debug(f"✅ Cache HIT: {key}")
                return json.loads(value)
            else:
                logger.debug(f"❌ Cache MISS: {key}")
                return None
        except RedisError as e:
            logger.error(f"Redis get error for key {key}: {e}")
            return None
        except json.JSONDecodeError as e:
            logger.error(f"JSON decode error for key {key}: {e}")
            return None
    
    def set(
        self, 
        key: str, 
        value: Any, 
        ttl: Optional[int] = None
    ) -> bool:
        """
        Store value in cache with optional TTL.
        
        Args:
            key: Cache key
            value: Value to cache (must be JSON serializable)
            ttl: Time to live in seconds (None = no expiration)
            
        Returns:
            bool: True if successful, False otherwise
        """
        if not self.cache_enabled or not self.redis_client:
            return False
        
        try:
            value_json = json.dumps(value)
            if ttl:
                self.redis_client.setex(key, ttl, value_json)
            else:
                self.redis_client.set(key, value_json)
            logger.debug(f"✅ Cache SET: {key} (TTL: {ttl}s)")
            return True
        except (RedisError, TypeError, ValueError) as e:
            logger.error(f"Redis set error for key {key}: {e}")
            return False
    
    def delete(self, key: str) -> bool:
        """
        Delete value from cache.
        
        Args:
            key: Cache key
            
        Returns:
            bool: True if deleted, False otherwise
        """
        if not self.cache_enabled or not self.redis_client:
            return False
        
        try:
            deleted = self.redis_client.delete(key)
            logger.debug(f"🗑️ Cache DELETE: {key} (deleted: {deleted})")
            return bool(deleted)
        except RedisError as e:
            logger.error(f"Redis delete error for key {key}: {e}")
            return False
    
    def clear_pattern(self, pattern: str) -> int:
        """
        Delete all keys matching pattern.
        
        Args:
            pattern: Redis key pattern (e.g., 'generation:*')
            
        Returns:
            int: Number of keys deleted
        """
        if not self.cache_enabled or not self.redis_client:
            return 0
        
        try:
            keys = self.redis_client.keys(pattern)
            if keys:
                deleted = self.redis_client.delete(*keys)
                logger.info(f"🗑️ Cache CLEAR: {pattern} ({deleted} keys)")
                return deleted
            return 0
        except RedisError as e:
            logger.error(f"Redis clear pattern error for {pattern}: {e}")
            return 0
    
    def get_stats(self) -> Dict[str, Any]:
        """
        Get cache statistics.
        
        Returns:
            dict: Cache statistics (keys, memory, hit_rate, etc.)
        """
        if not self.cache_enabled or not self.redis_client:
            return {
                "enabled": False,
                "available": False
            }
        
        try:
            info = self.redis_client.info()
            stats = self.redis_client.info('stats')
            
            # Calculate hit rate
            hits = stats.get('keyspace_hits', 0)
            misses = stats.get('keyspace_misses', 0)
            total = hits + misses
            hit_rate = (hits / total * 100) if total > 0 else 0
            
            return {
                "enabled": True,
                "available": True,
                "keys": info.get('db0', {}).get('keys', 0),
                "memory_used_mb": round(info.get('used_memory', 0) / 1024 / 1024, 2),
                "hits": hits,
                "misses": misses,
                "hit_rate": round(hit_rate, 2),
                "connected_clients": info.get('connected_clients', 0)
            }
        except RedisError as e:
            logger.error(f"Redis stats error: {e}")
            return {
                "enabled": True,
                "available": False,
                "error": str(e)
            }
    
    # Helper methods for specific cache types
    
    def cache_generation(
        self, 
        content_type: str, 
        prompt: str, 
        result: Dict[str, Any],
        user_id: str,
        ttl: int = 3600  # 1 hour default
    ) -> bool:
        """
        Cache an AI generation result.
        
        Args:
            content_type: Type of content (blog, social, etc.)
            prompt: User prompt
            result: Generation result
            user_id: User ID
            ttl: Cache duration in seconds
            
        Returns:
            bool: True if cached successfully
        """
        key = self._generate_cache_key(
            "generation",
            content_type=content_type,
            prompt=prompt,
            user_id=user_id
        )
        return self.set(key, result, ttl=ttl)
    
    def get_cached_generation(
        self, 
        content_type: str, 
        prompt: str,
        user_id: str
    ) -> Optional[Dict[str, Any]]:
        """
        Retrieve cached generation result.
        
        Args:
            content_type: Type of content
            prompt: User prompt
            user_id: User ID
            
        Returns:
            Cached result or None
        """
        key = self._generate_cache_key(
            "generation",
            content_type=content_type,
            prompt=prompt,
            user_id=user_id
        )
        return self.get(key)
    
    def cache_enhanced_prompt(
        self, 
        content_type: str, 
        raw_prompt: str,
        enhanced_prompt: str,
        ttl: int = 86400  # 24 hours
    ) -> bool:
        """
        Cache an enhanced prompt.
        
        Args:
            content_type: Content type
            raw_prompt: Original user prompt
            enhanced_prompt: Enhanced prompt
            ttl: Cache duration
            
        Returns:
            bool: True if cached
        """
        key = self._generate_cache_key(
            "prompt",
            content_type=content_type,
            raw_prompt=raw_prompt
        )
        return self.set(key, enhanced_prompt, ttl=ttl)
    
    def get_cached_prompt(
        self, 
        content_type: str, 
        raw_prompt: str
    ) -> Optional[str]:
        """
        Retrieve cached enhanced prompt.
        
        Args:
            content_type: Content type
            raw_prompt: Original prompt
            
        Returns:
            Enhanced prompt or None
        """
        key = self._generate_cache_key(
            "prompt",
            content_type=content_type,
            raw_prompt=raw_prompt
        )
        return self.get(key)


# Global cache manager instance
cache_manager = CacheManager()
