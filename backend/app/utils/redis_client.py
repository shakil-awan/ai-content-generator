"""
Redis Client - Rate Limiting & Caching
Connection manager for Redis operations
"""
from typing import Optional
import redis.asyncio as redis
from app.config import settings
import logging

logger = logging.getLogger(__name__)

class RedisClient:
    _instance: Optional['RedisClient'] = None
    _client: Optional[redis.Redis] = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    async def connect(self):
        """Initialize Redis connection"""
        if self._client is None:
            try:
                self._client = redis.Redis(
                    host=settings.REDIS_HOST,
                    port=settings.REDIS_PORT,
                    db=settings.REDIS_DB,
                    decode_responses=True
                )
                await self._client.ping()
                logger.info(f"Redis connected: {settings.REDIS_HOST}:{settings.REDIS_PORT}")
            except Exception as e:
                logger.warning(f"Redis connection failed: {e}. Rate limiting will use Firestore only.")
                self._client = None
    
    async def disconnect(self):
        """Close Redis connection"""
        if self._client:
            await self._client.close()
            logger.info("Redis disconnected")
    
    @property
    def client(self) -> Optional[redis.Redis]:
        """Get Redis client instance"""
        return self._client
    
    async def get(self, key: str) -> Optional[str]:
        """Get value from Redis"""
        if not self._client:
            return None
        try:
            return await self._client.get(key)
        except Exception as e:
            logger.error(f"Redis GET error: {e}")
            return None
    
    async def set(self, key: str, value: str, ex: Optional[int] = None) -> bool:
        """Set value in Redis with optional expiration"""
        if not self._client:
            return False
        try:
            await self._client.set(key, value, ex=ex)
            return True
        except Exception as e:
            logger.error(f"Redis SET error: {e}")
            return False
    
    async def incr(self, key: str) -> Optional[int]:
        """Increment counter in Redis"""
        if not self._client:
            return None
        try:
            return await self._client.incr(key)
        except Exception as e:
            logger.error(f"Redis INCR error: {e}")
            return None
    
    async def expire(self, key: str, seconds: int) -> bool:
        """Set key expiration"""
        if not self._client:
            return False
        try:
            await self._client.expire(key, seconds)
            return True
        except Exception as e:
            logger.error(f"Redis EXPIRE error: {e}")
            return False
    
    async def delete(self, key: str) -> bool:
        """Delete key from Redis"""
        if not self._client:
            return False
        try:
            await self._client.delete(key)
            return True
        except Exception as e:
            logger.error(f"Redis DELETE error: {e}")
            return False
    
    async def exists(self, key: str) -> bool:
        """Check if key exists"""
        if not self._client:
            return False
        try:
            return await self._client.exists(key) > 0
        except Exception as e:
            logger.error(f"Redis EXISTS error: {e}")
            return False
    
    async def ttl(self, key: str) -> int:
        """Get time-to-live for key"""
        if not self._client:
            return -2
        try:
            return await self._client.ttl(key)
        except Exception as e:
            logger.error(f"Redis TTL error: {e}")
            return -2

# Singleton instance
redis_client = RedisClient()
