"""
Pytest configuration and shared fixtures for all tests.
"""
import os
import sys
import asyncio
from typing import AsyncGenerator, Generator
import pytest
from fastapi.testclient import TestClient
from unittest.mock import Mock, AsyncMock, patch

# Add the backend directory to the Python path
sys.path.insert(0, os.path.dirname(__file__))

# Set test environment variables
os.environ["TESTING"] = "true"
os.environ["CACHE_ENABLED"] = "true"
os.environ["REDIS_HOST"] = "localhost"
os.environ["REDIS_PORT"] = "6379"


@pytest.fixture(scope="session")
def event_loop():
    """Create an event loop for the entire test session."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="function")
def mock_firebase_db():
    """Mock Firebase Firestore database."""
    mock_db = Mock()
    
    # Mock collection
    mock_collection = Mock()
    mock_db.collection.return_value = mock_collection
    
    # Mock document
    mock_doc = Mock()
    mock_collection.document.return_value = mock_doc
    
    # Mock set/get operations
    mock_doc.set = AsyncMock()
    mock_doc.get = AsyncMock(return_value=Mock(exists=True, to_dict=lambda: {}))
    
    return mock_db


@pytest.fixture(scope="function")
def mock_firebase_auth():
    """Mock Firebase Auth."""
    mock_auth = Mock()
    mock_auth.verify_id_token = AsyncMock(return_value={"uid": "test_user_123"})
    mock_auth.get_user = AsyncMock(return_value=Mock(uid="test_user_123", email="test@example.com"))
    return mock_auth


@pytest.fixture(scope="function")
def mock_redis():
    """Mock Redis client."""
    mock_redis = Mock()
    mock_redis.get = AsyncMock(return_value=None)
    mock_redis.set = AsyncMock(return_value=True)
    mock_redis.delete = AsyncMock(return_value=1)
    mock_redis.exists = AsyncMock(return_value=0)
    mock_redis.ttl = AsyncMock(return_value=-1)
    mock_redis.info = AsyncMock(return_value={
        "keyspace_hits": 100,
        "keyspace_misses": 150,
        "used_memory_human": "10M"
    })
    return mock_redis


@pytest.fixture(scope="function")
def mock_openai_client():
    """Mock OpenAI client."""
    mock_client = Mock()
    
    # Mock ChatCompletion
    mock_response = Mock()
    mock_response.choices = [Mock(message=Mock(content="Test generated content"))]
    mock_response.usage = Mock(
        prompt_tokens=100,
        completion_tokens=200,
        total_tokens=300
    )
    mock_response.model = "gpt-4o-mini"
    
    mock_client.chat.completions.create = AsyncMock(return_value=mock_response)
    
    return mock_client


@pytest.fixture(scope="function")
def mock_gemini_client():
    """Mock Google Gemini client."""
    mock_client = Mock()
    
    # Mock GenerativeModel
    mock_model = Mock()
    mock_response = Mock()
    mock_response.text = "Test generated content from Gemini"
    mock_response.usage_metadata = Mock(
        prompt_token_count=100,
        candidates_token_count=200,
        total_token_count=300
    )
    
    mock_model.generate_content_async = AsyncMock(return_value=mock_response)
    mock_client.GenerativeModel = Mock(return_value=mock_model)
    
    return mock_client


@pytest.fixture(scope="function")
def sample_blog_request():
    """Sample blog generation request."""
    return {
        "topic": "The Future of AI in Content Creation",
        "keywords": ["AI", "content creation", "automation", "machine learning"],
        "tone": "professional",
        "word_count": 1000,
        "target_audience": "marketing professionals",
        "use_premium": False
    }


@pytest.fixture(scope="function")
def sample_social_media_request():
    """Sample social media generation request."""
    return {
        "platform": "twitter",
        "topic": "New AI features launched",
        "tone": "exciting",
        "hashtags": ["AI", "TechNews", "Innovation"],
        "include_cta": True,
        "use_premium": False
    }


@pytest.fixture(scope="function")
def sample_email_request():
    """Sample email campaign request."""
    return {
        "campaign_type": "product_launch",
        "product_name": "AI Content Generator Pro",
        "target_audience": "small business owners",
        "tone": "friendly",
        "key_benefits": ["Save time", "Improve quality", "Reduce costs"],
        "use_premium": False
    }


@pytest.fixture(scope="function")
def sample_quality_score():
    """Sample quality score for testing."""
    return {
        "overall": 0.75,
        "readability": 0.70,
        "completeness": 0.80,
        "seo": 0.75,
        "grammar": 0.75,
        "grade": "B",
        "details": {
            "readability_details": {
                "flesch_kincaid": 65.0,
                "avg_sentence_length": 15.5,
                "avg_word_length": 4.8
            },
            "completeness_details": {
                "word_count": 950,
                "target_word_count": 1000,
                "has_structure": True
            },
            "seo_details": {
                "keyword_presence": True,
                "keyword_density": 0.025,
                "has_headings": True
            },
            "grammar_details": {
                "capitalization_ok": True,
                "punctuation_ok": True
            }
        }
    }


@pytest.fixture(scope="function")
def mock_cache_manager(mock_redis):
    """Mock cache manager with Redis."""
    from app.utils.cache_manager import cache_manager
    original_redis = cache_manager.redis_client
    cache_manager.redis_client = mock_redis
    yield cache_manager
    cache_manager.redis_client = original_redis


@pytest.fixture(scope="function")
def test_client():
    """Create a test client for the FastAPI app."""
    from app.main import app
    
    # Override dependencies for testing
    with TestClient(app) as client:
        yield client


@pytest.fixture(scope="function", autouse=True)
def reset_singletons():
    """Reset singleton instances between tests."""
    yield
    # Reset cache manager stats
    from app.utils.cache_manager import cache_manager
    cache_manager.stats = {
        "hits": 0,
        "misses": 0,
        "sets": 0,
        "deletes": 0,
        "errors": 0
    }


# Pytest hooks for custom behavior
def pytest_configure(config):
    """Configure pytest with custom settings."""
    config.addinivalue_line(
        "markers", "integration: mark test as an integration test"
    )
    config.addinivalue_line(
        "markers", "unit: mark test as a unit test"
    )


def pytest_collection_modifyitems(config, items):
    """Modify test items during collection."""
    for item in items:
        # Add 'unit' marker to tests in test_* files (not in integration/)
        if "integration" not in str(item.fspath):
            item.add_marker(pytest.mark.unit)
        
        # Add 'integration' marker to tests in integration/ directory
        if "integration" in str(item.fspath):
            item.add_marker(pytest.mark.integration)


# Performance testing utilities
@pytest.fixture(scope="function")
def performance_timer():
    """Utility to measure performance."""
    import time
    
    class Timer:
        def __init__(self):
            self.start_time = None
            self.end_time = None
            self.elapsed = None
        
        def start(self):
            self.start_time = time.time()
        
        def stop(self):
            self.end_time = time.time()
            self.elapsed = self.end_time - self.start_time
            return self.elapsed
        
        def __enter__(self):
            self.start()
            return self
        
        def __exit__(self, *args):
            self.stop()
    
    return Timer()
