"""
Quality Scoring API Router
Provides endpoints for content quality evaluation and improvement suggestions
"""
from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict, Any
import logging

from app.schemas.quality import (
    QualityScoreRequest,
    QualityScoreResponse,
    QualityDetails,
    QualityImprovementRequest,
    QualityImprovementResponse
)
from app.utils.quality_scorer import quality_scorer, QualityScore
from app.dependencies import get_current_user

router = APIRouter(prefix="/api/v1/quality", tags=["Quality Scoring"])
logger = logging.getLogger(__name__)


@router.post(
    "/score",
    response_model=QualityScoreResponse,
    summary="Score content quality",
    description="""
    Evaluate content quality across multiple dimensions.
    
    **Scoring Components:**
    - **Readability (30%)**: Flesch-Kincaid readability score
    - **Completeness (30%)**: Word count, structure, depth
    - **SEO (20%)**: Keyword presence and density
    - **Grammar (20%)**: Basic grammar and style checks
    
    **Use Cases:**
    - Score generated content before saving
    - Re-score edited content
    - Compare multiple versions
    - Validate content before publishing
    
    **Note:** No authentication required for this endpoint
    """
)
async def score_content(
    request: QualityScoreRequest
) -> QualityScoreResponse:
    """
    Score content quality independently (no generation required)
    
    Args:
        request: Content and metadata for scoring
    
    Returns:
        Detailed quality score breakdown with improvement flag
    """
    try:
        # Prepare metadata for scorer
        metadata = {
            'target_length': request.target_length,
            'keywords': request.keywords or []
        }
        
        # Score the content
        quality_score = quality_scorer.score_content(
            content=request.content,
            content_type=request.content_type,
            metadata=metadata
        )
        
        logger.info(
            f"Content scored: {request.content_type} | "
            f"Overall: {quality_score.overall:.2f} | "
            f"Grade: {quality_score._get_grade()}"
        )
        
        # Convert to response format
        response = QualityScoreResponse(
            overall=quality_score.overall,
            readability=quality_score.readability,
            completeness=quality_score.completeness,
            seo=quality_score.seo,
            grammar=quality_score.grammar,
            grade=quality_score._get_grade(),
            percentage=int(quality_score.overall * 100),
            details=QualityDetails(
                word_count=quality_score.details.get('word_count', 0),
                sentence_count=quality_score.details.get('sentence_count', 0),
                avg_sentence_length=quality_score.details.get('avg_sentence_length', 0.0),
                paragraph_count=quality_score.details.get('paragraph_count', 0),
                flesch_kincaid_score=quality_score.details.get('flesch_kincaid_score', 0.0)
            ),
            should_regenerate=quality_scorer.should_regenerate(quality_score)
        )
        
        return response
        
    except Exception as e:
        logger.error(f"Error scoring content: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "quality_scoring_failed",
                "message": "Failed to score content quality. Please try again.",
                "details": str(e)
            }
        )


@router.post(
    "/suggestions",
    response_model=QualityImprovementResponse,
    summary="Get improvement suggestions",
    description="""
    Get personalized improvement suggestions based on quality scores.
    
    **Provides:**
    - Specific actionable suggestions
    - Priority areas that need most improvement
    - Strengths to maintain
    
    **Use Cases:**
    - Guide content editing
    - Show user what to improve
    - Provide context for low scores
    - Help reach target quality threshold
    """
)
async def get_improvement_suggestions(
    request: QualityImprovementRequest
) -> QualityImprovementResponse:
    """
    Generate improvement suggestions based on quality scores
    
    Args:
        request: Quality score breakdown
    
    Returns:
        Improvement suggestions with priority areas
    """
    try:
        # Create QualityScore object from request
        quality_score = QualityScore(
            overall=request.overall,
            readability=request.readability,
            completeness=request.completeness,
            seo=request.seo,
            grammar=request.grammar,
            details={}
        )
        
        # Get suggestions from scorer
        suggestions = quality_scorer.get_improvement_suggestions(quality_score)
        
        # Determine priority areas (scores < 0.70)
        priority_areas = []
        if request.readability < 0.70:
            priority_areas.append("readability")
        if request.completeness < 0.70:
            priority_areas.append("completeness")
        if request.seo < 0.70:
            priority_areas.append("seo")
        if request.grammar < 0.80:
            priority_areas.append("grammar")
        
        # Determine strengths (scores >= 0.80)
        strengths = []
        if request.readability >= 0.80:
            strengths.append("readability")
        if request.completeness >= 0.80:
            strengths.append("completeness")
        if request.seo >= 0.80:
            strengths.append("seo")
        if request.grammar >= 0.80:
            strengths.append("grammar")
        
        logger.info(
            f"Suggestions generated | Overall: {request.overall:.2f} | "
            f"Priority: {', '.join(priority_areas) if priority_areas else 'None'}"
        )
        
        return QualityImprovementResponse(
            suggestions=suggestions,
            priority_areas=priority_areas,
            strengths=strengths
        )
        
    except Exception as e:
        logger.error(f"Error generating suggestions: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "suggestions_failed",
                "message": "Failed to generate improvement suggestions. Please try again.",
                "details": str(e)
            }
        )


@router.get(
    "/thresholds",
    summary="Get quality thresholds",
    description="""
    Get the quality score thresholds used by the system.
    
    **Thresholds:**
    - **Excellent**: ≥ 0.80 (A grade) - Ready to publish
    - **Good**: ≥ 0.70 (B grade) - Acceptable quality
    - **Regenerate**: < 0.60 (D grade) - Should regenerate
    
    **Use Cases:**
    - Display threshold markers in UI
    - Set quality goals
    - Understand scoring system
    """
)
async def get_quality_thresholds() -> Dict[str, Any]:
    """
    Get quality scoring thresholds
    
    Returns:
        Dictionary of quality thresholds and grade mappings
    """
    return {
        "thresholds": {
            "excellent": quality_scorer.EXCELLENT_THRESHOLD,
            "good": quality_scorer.GOOD_THRESHOLD,
            "regenerate": quality_scorer.REGENERATE_THRESHOLD
        },
        "grade_mapping": {
            "A+": {"min": 0.90, "max": 1.00},
            "A": {"min": 0.80, "max": 0.89},
            "B": {"min": 0.70, "max": 0.79},
            "C": {"min": 0.60, "max": 0.69},
            "D": {"min": 0.00, "max": 0.59}
        },
        "component_weights": {
            "readability": 0.30,
            "completeness": 0.30,
            "seo": 0.20,
            "grammar": 0.20
        }
    }
