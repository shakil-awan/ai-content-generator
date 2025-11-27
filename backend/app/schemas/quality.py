"""
Quality Score Schemas
Pydantic models for quality scoring API requests/responses
"""
from pydantic import BaseModel, Field
from typing import Dict, Any, List, Optional


class QualityScoreRequest(BaseModel):
    """Request to score content quality"""
    content: str = Field(..., description="Content to score", min_length=10)
    content_type: str = Field(
        ..., 
        description="Type of content: blog, social_media, email, product, ad, video"
    )
    keywords: Optional[List[str]] = Field(
        default=None, 
        description="Keywords for SEO scoring"
    )
    target_length: Optional[int] = Field(
        default=500, 
        description="Target word count for completeness scoring"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "content": "This is a sample blog post about AI. It contains multiple paragraphs and demonstrates good structure.",
                "content_type": "blog",
                "keywords": ["AI", "technology"],
                "target_length": 500
            }
        }


class QualityDetails(BaseModel):
    """Detailed quality metrics"""
    word_count: int
    sentence_count: int
    avg_sentence_length: float
    paragraph_count: int
    flesch_kincaid_score: float


class QualityScoreResponse(BaseModel):
    """Quality score response"""
    overall: float = Field(..., description="Overall quality score (0.0-1.0)")
    readability: float = Field(..., description="Readability score (0.0-1.0)")
    completeness: float = Field(..., description="Completeness score (0.0-1.0)")
    seo: float = Field(..., description="SEO quality score (0.0-1.0)")
    grammar: float = Field(..., description="Grammar score (0.0-1.0)")
    grade: str = Field(..., description="Letter grade (A+, A, B, C, D)")
    percentage: int = Field(..., description="Percentage score (0-100)")
    details: QualityDetails
    should_regenerate: bool = Field(
        ..., 
        description="Whether content should be regenerated due to low quality"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "overall": 0.82,
                "readability": 0.85,
                "completeness": 0.78,
                "seo": 0.80,
                "grammar": 0.85,
                "grade": "A",
                "percentage": 82,
                "details": {
                    "word_count": 520,
                    "sentence_count": 25,
                    "avg_sentence_length": 20.8,
                    "paragraph_count": 5,
                    "flesch_kincaid_score": 72.5
                },
                "should_regenerate": False
            }
        }


class QualityImprovementRequest(BaseModel):
    """Request for improvement suggestions"""
    overall: float = Field(..., ge=0.0, le=1.0)
    readability: float = Field(..., ge=0.0, le=1.0)
    completeness: float = Field(..., ge=0.0, le=1.0)
    seo: float = Field(..., ge=0.0, le=1.0)
    grammar: float = Field(..., ge=0.0, le=1.0)
    
    class Config:
        json_schema_extra = {
            "example": {
                "overall": 0.65,
                "readability": 0.55,
                "completeness": 0.70,
                "seo": 0.65,
                "grammar": 0.75
            }
        }


class QualityImprovementResponse(BaseModel):
    """Improvement suggestions response"""
    suggestions: List[str] = Field(..., description="List of improvement suggestions")
    priority_areas: List[str] = Field(
        ..., 
        description="Areas that need most improvement"
    )
    strengths: List[str] = Field(..., description="Strong areas of the content")
    
    class Config:
        json_schema_extra = {
            "example": {
                "suggestions": [
                    "📖 Improve readability: Use shorter sentences and simpler words",
                    "🔍 Enhance SEO: Include more keywords naturally and add headings"
                ],
                "priority_areas": ["readability", "seo"],
                "strengths": ["grammar", "completeness"]
            }
        }
