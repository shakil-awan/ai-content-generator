"""
Unit tests for Quality Scoring API endpoints
Tests all quality-related endpoints with various scenarios
"""
import pytest
from fastapi import status
from app.schemas.quality import (
    QualityScoreRequest,
    QualityScoreResponse,
    QualityImprovementRequest
)


class TestQualityScoreEndpoint:
    """Test POST /api/v1/quality/score endpoint"""
    
    @pytest.mark.asyncio
    async def test_score_blog_content_success(self, test_client):
        """Test scoring blog content successfully"""
        request_data = {
            "content": """
            # The Future of AI in Healthcare
            
            Artificial intelligence is revolutionizing healthcare. Machine learning algorithms 
            can now detect diseases earlier than ever before. This technology is improving 
            patient outcomes and reducing costs.
            
            ## Benefits of AI in Medicine
            
            AI helps doctors make better decisions. It analyzes medical images faster and 
            more accurately than humans. The future looks bright for AI-powered healthcare.
            """,
            "content_type": "blog",
            "keywords": ["AI", "healthcare", "machine learning"],
            "target_length": 200
        }
        
        response = test_client.post("/api/v1/quality/score", json=request_data)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        
        # Check response structure
        assert "overall" in data
        assert "readability" in data
        assert "completeness" in data
        assert "seo" in data
        assert "grammar" in data
        assert "grade" in data
        assert "percentage" in data
        assert "details" in data
        assert "should_regenerate" in data
        
        # Check score ranges
        assert 0.0 <= data["overall"] <= 1.0
        assert 0.0 <= data["readability"] <= 1.0
        assert 0.0 <= data["completeness"] <= 1.0
        assert 0.0 <= data["seo"] <= 1.0
        assert 0.0 <= data["grammar"] <= 1.0
        
        # Check grade is valid
        assert data["grade"] in ["A+", "A", "B", "C", "D"]
        
        # Check details structure
        assert "word_count" in data["details"]
        assert "sentence_count" in data["details"]
        assert "avg_sentence_length" in data["details"]
        assert "paragraph_count" in data["details"]
        assert "flesch_kincaid_score" in data["details"]
    
    @pytest.mark.asyncio
    async def test_score_short_content(self, test_client):
        """Test scoring very short content"""
        request_data = {
            "content": "This is a very short blog post.",
            "content_type": "blog",
            "target_length": 500
        }
        
        response = test_client.post("/api/v1/quality/score", json=request_data)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        
        # Short content should have lower completeness score
        assert data["completeness"] < 0.70
        # Should recommend regeneration
        assert data["should_regenerate"] is True
    
    @pytest.mark.asyncio
    async def test_score_high_quality_content(self, test_client):
        """Test scoring high-quality well-structured content"""
        request_data = {
            "content": """
            # Comprehensive Guide to Machine Learning
            
            Machine learning has become an essential tool in modern technology. This guide 
            explores the fundamentals, applications, and best practices for implementing 
            ML solutions effectively.
            
            ## Understanding the Basics
            
            Machine learning enables computers to learn from data. Unlike traditional 
            programming, ML algorithms improve through experience. This makes them 
            incredibly powerful for pattern recognition.
            
            ## Practical Applications
            
            Today's ML systems power everything from recommendation engines to autonomous 
            vehicles. For example, Netflix uses ML to suggest content. Similarly, Tesla 
            employs ML for self-driving features.
            
            ## Implementation Best Practices
            
            Start with clean, well-labeled data. Use cross-validation to test your models. 
            Always monitor performance in production. These practices ensure reliable results.
            
            ## Conclusion
            
            Machine learning continues to evolve rapidly. By following best practices and 
            staying current with research, you can build effective ML solutions. The future 
            of AI is bright and full of possibilities.
            """,
            "content_type": "blog",
            "keywords": ["machine learning", "ML", "artificial intelligence", "data"],
            "target_length": 300
        }
        
        response = test_client.post("/api/v1/quality/score", json=request_data)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        
        # High quality content should score well
        assert data["overall"] >= 0.70
        assert data["grade"] in ["A+", "A", "B"]
        assert data["should_regenerate"] is False
        
        # Should have good structure
        assert data["details"]["paragraph_count"] >= 4
        assert data["details"]["word_count"] >= 200
    
    @pytest.mark.asyncio
    async def test_score_social_media_content(self, test_client):
        """Test scoring social media post"""
        request_data = {
            "content": "🚀 Exciting news! We're launching our new AI tool! Check it out! #AI #Technology #Innovation",
            "content_type": "social_media",
            "target_length": 280
        }
        
        response = test_client.post("/api/v1/quality/score", json=request_data)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        
        # Social media has different scoring criteria
        assert 0.0 <= data["overall"] <= 1.0
        assert data["details"]["word_count"] <= 50
    
    @pytest.mark.asyncio
    async def test_score_email_content(self, test_client):
        """Test scoring email content"""
        request_data = {
            "content": """
            Dear Customer,
            
            We're excited to introduce our new product lineup! Click here to learn more 
            about our latest innovations and special offers.
            
            Visit our website today to get started!
            
            Best regards,
            The Team
            """,
            "content_type": "email",
            "target_length": 150
        }
        
        response = test_client.post("/api/v1/quality/score", json=request_data)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        
        # Email should score reasonably if it has intro/cta/closing
        assert data["overall"] > 0.0
    
    @pytest.mark.asyncio
    async def test_score_missing_content(self, test_client):
        """Test error handling for missing content"""
        request_data = {
            "content_type": "blog",
            "target_length": 500
        }
        
        response = test_client.post("/api/v1/quality/score", json=request_data)
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY
    
    @pytest.mark.asyncio
    async def test_score_invalid_content_type(self, test_client):
        """Test with invalid content type (should still work)"""
        request_data = {
            "content": "This is test content with unknown type.",
            "content_type": "unknown_type",
            "target_length": 100
        }
        
        response = test_client.post("/api/v1/quality/score", json=request_data)
        
        # Should still work with default scoring
        assert response.status_code == status.HTTP_200_OK
    
    @pytest.mark.asyncio
    async def test_score_with_keywords(self, test_client):
        """Test SEO scoring with keywords"""
        request_data = {
            "content": """
            Machine learning is transforming industries. AI and machine learning 
            algorithms enable intelligent automation. The future of artificial 
            intelligence looks promising.
            """,
            "content_type": "blog",
            "keywords": ["machine learning", "AI", "artificial intelligence"],
            "target_length": 100
        }
        
        response = test_client.post("/api/v1/quality/score", json=request_data)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        
        # Should have good SEO score due to keyword presence
        assert data["seo"] > 0.50


class TestQualityImprovementEndpoint:
    """Test POST /api/v1/quality/suggestions endpoint"""
    
    @pytest.mark.asyncio
    async def test_get_suggestions_low_quality(self, test_client):
        """Test getting suggestions for low quality content"""
        request_data = {
            "overall": 0.55,
            "readability": 0.45,
            "completeness": 0.60,
            "seo": 0.50,
            "grammar": 0.65
        }
        
        response = test_client.post("/api/v1/quality/suggestions", json=request_data)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        
        # Check response structure
        assert "suggestions" in data
        assert "priority_areas" in data
        assert "strengths" in data
        
        # Should have multiple suggestions for low quality
        assert len(data["suggestions"]) > 0
        
        # Should identify priority areas
        assert len(data["priority_areas"]) >= 2
        assert "readability" in data["priority_areas"]
        assert "seo" in data["priority_areas"]
    
    @pytest.mark.asyncio
    async def test_get_suggestions_high_quality(self, test_client):
        """Test getting suggestions for high quality content"""
        request_data = {
            "overall": 0.88,
            "readability": 0.90,
            "completeness": 0.85,
            "seo": 0.88,
            "grammar": 0.90
        }
        
        response = test_client.post("/api/v1/quality/suggestions", json=request_data)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        
        # Should have positive feedback
        assert len(data["suggestions"]) > 0
        
        # Should have minimal priority areas
        assert len(data["priority_areas"]) == 0
        
        # Should identify multiple strengths
        assert len(data["strengths"]) >= 3
    
    @pytest.mark.asyncio
    async def test_get_suggestions_mixed_quality(self, test_client):
        """Test suggestions for mixed quality scores"""
        request_data = {
            "overall": 0.72,
            "readability": 0.85,
            "completeness": 0.80,
            "seo": 0.60,
            "grammar": 0.65
        }
        
        response = test_client.post("/api/v1/quality/suggestions", json=request_data)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        
        # Should identify specific areas needing improvement
        assert "seo" in data["priority_areas"]
        
        # Should identify strengths
        assert "readability" in data["strengths"]
        assert "completeness" in data["strengths"]
    
    @pytest.mark.asyncio
    async def test_suggestions_invalid_scores(self, test_client):
        """Test error handling for invalid score values"""
        request_data = {
            "overall": 1.5,  # Invalid: > 1.0
            "readability": 0.80,
            "completeness": 0.80,
            "seo": 0.80,
            "grammar": 0.80
        }
        
        response = test_client.post("/api/v1/quality/suggestions", json=request_data)
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


class TestQualityThresholdsEndpoint:
    """Test GET /api/v1/quality/thresholds endpoint"""
    
    @pytest.mark.asyncio
    async def test_get_thresholds(self, test_client):
        """Test getting quality thresholds"""
        response = test_client.get("/api/v1/quality/thresholds")
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        
        # Check structure
        assert "thresholds" in data
        assert "grade_mapping" in data
        assert "component_weights" in data
        
        # Check threshold values
        thresholds = data["thresholds"]
        assert "excellent" in thresholds
        assert "good" in thresholds
        assert "regenerate" in thresholds
        
        # Verify threshold values
        assert thresholds["excellent"] == 0.80
        assert thresholds["good"] == 0.70
        assert thresholds["regenerate"] == 0.60
        
        # Check grade mapping
        grades = data["grade_mapping"]
        assert "A+" in grades
        assert "A" in grades
        assert "B" in grades
        assert "C" in grades
        assert "D" in grades
        
        # Check component weights
        weights = data["component_weights"]
        assert weights["readability"] == 0.30
        assert weights["completeness"] == 0.30
        assert weights["seo"] == 0.20
        assert weights["grammar"] == 0.20
        
        # Weights should sum to 1.0
        assert sum(weights.values()) == 1.0


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
