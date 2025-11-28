"""
Analytics & Cost Tracking API
Real-time cost monitoring, usage analytics, cache statistics
"""
from fastapi import APIRouter, Depends, HTTPException
from typing import Dict, Any, List, Optional
from datetime import datetime, timedelta
import logging

from app.dependencies import get_current_user
from app.utils.cache_manager import cache_manager
from app.config import settings
from firebase_admin import firestore

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/analytics", tags=["Analytics"])

# Initialize Firestore client
db = firestore.client()


@router.get("/cache/stats")
async def get_cache_stats(
    current_user: dict = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Get Redis cache statistics
    
    Returns cache health, hit rate, memory usage
    """
    try:
        stats = cache_manager.get_stats()
        
        return {
            "success": True,
            "data": stats,
            "recommendations": _get_cache_recommendations(stats)
        }
    except Exception as e:
        logger.error(f"Error fetching cache stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/cost/summary")
async def get_cost_summary(
    days: int = 30,
    current_user: dict = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Get cost summary for specified period
    
    Args:
        days: Number of days to analyze (default 30)
    
    Returns:
        Cost breakdown by model, content type, user tier
    """
    try:
        user_id = current_user.get('uid')
        user_tier = current_user.get('subscriptionPlan', 'free')
        
        # Calculate date range
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days)
        
        # Query cost tracking data from Firestore
        cost_collection = db.collection(settings.COST_TRACKING_DB_COLLECTION)
        
        if user_tier in ['admin', 'enterprise']:
            # Admin/Enterprise can see all costs
            query = cost_collection.where('timestamp', '>=', start_date)
        else:
            # Regular users see only their costs
            query = cost_collection.where('user_id', '==', user_id).where('timestamp', '>=', start_date)
        
        docs = query.stream()
        
        # Aggregate costs
        total_cost = 0.0
        costs_by_model = {}
        costs_by_content_type = {}
        generation_count = 0
        cached_count = 0
        
        for doc in docs:
            data = doc.to_dict()
            cost = data.get('cost', 0.0)
            model = data.get('model', 'unknown')
            content_type = data.get('content_type', 'unknown')
            cached = data.get('cached', False)
            
            total_cost += cost
            generation_count += 1
            
            if cached:
                cached_count += 1
            
            # Aggregate by model
            costs_by_model[model] = costs_by_model.get(model, 0.0) + cost
            
            # Aggregate by content type
            costs_by_content_type[content_type] = costs_by_content_type.get(content_type, 0.0) + cost
        
        cache_hit_rate = (cached_count / generation_count * 100) if generation_count > 0 else 0
        avg_cost_per_generation = total_cost / generation_count if generation_count > 0 else 0
        
        # Calculate projected monthly cost
        days_in_period = (end_date - start_date).days
        projected_monthly_cost = (total_cost / days_in_period) * 30 if days_in_period > 0 else 0
        
        return {
            "success": True,
            "data": {
                "period": {
                    "start": start_date.isoformat(),
                    "end": end_date.isoformat(),
                    "days": days
                },
                "summary": {
                    "total_cost": round(total_cost, 4),
                    "generation_count": generation_count,
                    "cached_count": cached_count,
                    "cache_hit_rate": round(cache_hit_rate, 2),
                    "avg_cost_per_generation": round(avg_cost_per_generation, 6),
                    "projected_monthly_cost": round(projected_monthly_cost, 2)
                },
                "by_model": {k: round(v, 4) for k, v in costs_by_model.items()},
                "by_content_type": {k: round(v, 4) for k, v in costs_by_content_type.items()}
            },
            "insights": _generate_cost_insights(
                total_cost, 
                cache_hit_rate, 
                avg_cost_per_generation,
                costs_by_model
            )
        }
    except Exception as e:
        logger.error(f"Error fetching cost summary: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/usage/breakdown")
async def get_usage_breakdown(
    days: int = 7,
    current_user: dict = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Get detailed usage breakdown
    
    Args:
        days: Number of days to analyze
    
    Returns:
        Usage by content type, hour of day, day of week
    """
    try:
        user_id = current_user.get('uid')
        user_tier = current_user.get('subscriptionPlan', 'free')
        
        # Calculate date range
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days)
        
        # Query usage data
        cost_collection = db.collection(settings.COST_TRACKING_DB_COLLECTION)
        
        if user_tier in ['admin', 'enterprise']:
            query = cost_collection.where('timestamp', '>=', start_date)
        else:
            query = cost_collection.where('user_id', '==', user_id).where('timestamp', '>=', start_date)
        
        docs = query.stream()
        
        # Aggregate usage patterns
        usage_by_hour = {i: 0 for i in range(24)}
        usage_by_day = {i: 0 for i in range(7)}  # 0=Monday
        usage_by_content_type = {}
        model_performance = {}
        
        for doc in docs:
            data = doc.to_dict()
            timestamp = data.get('timestamp')
            content_type = data.get('content_type', 'unknown')
            model = data.get('model', 'unknown')
            generation_time = data.get('generation_time', 0)
            
            if timestamp:
                hour = timestamp.hour
                day = timestamp.weekday()
                usage_by_hour[hour] += 1
                usage_by_day[day] += 1
            
            usage_by_content_type[content_type] = usage_by_content_type.get(content_type, 0) + 1
            
            if model not in model_performance:
                model_performance[model] = {'count': 0, 'total_time': 0}
            model_performance[model]['count'] += 1
            model_performance[model]['total_time'] += generation_time
        
        # Calculate average generation times
        for model in model_performance:
            count = model_performance[model]['count']
            total_time = model_performance[model]['total_time']
            model_performance[model]['avg_time'] = round(total_time / count, 2) if count > 0 else 0
        
        return {
            "success": True,
            "data": {
                "period": {
                    "start": start_date.isoformat(),
                    "end": end_date.isoformat()
                },
                "usage_by_hour": usage_by_hour,
                "usage_by_day": {
                    "Monday": usage_by_day[0],
                    "Tuesday": usage_by_day[1],
                    "Wednesday": usage_by_day[2],
                    "Thursday": usage_by_day[3],
                    "Friday": usage_by_day[4],
                    "Saturday": usage_by_day[5],
                    "Sunday": usage_by_day[6]
                },
                "usage_by_content_type": usage_by_content_type,
                "model_performance": model_performance
            }
        }
    except Exception as e:
        logger.error(f"Error fetching usage breakdown: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/cost/track")
async def track_generation_cost(
    generation_data: Dict[str, Any],
    current_user: dict = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Track a generation's cost (called internally by services)
    
    Args:
        generation_data: Generation metadata (model, tokens, content_type, etc.)
    
    Returns:
        Confirmation with cost calculation
    """
    try:
        if not settings.ENABLE_COST_TRACKING:
            return {
                "success": True,
                "message": "Cost tracking disabled",
                "cost": 0
            }
        
        user_id = current_user.get('uid')
        model = generation_data.get('model', 'unknown')
        content_type = generation_data.get('content_type', 'unknown')
        tokens_used = generation_data.get('tokensUsed', 0)
        cached = generation_data.get('cached', False)
        cached_prompt = generation_data.get('cached_prompt', False)
        generation_time = generation_data.get('generation_time', 0)
        
        # Calculate cost based on model
        cost = _calculate_generation_cost(
            model=model,
            tokens_used=tokens_used,
            cached=cached,
            cached_prompt=cached_prompt
        )
        
        # Store in Firestore
        cost_doc = {
            'user_id': user_id,
            'model': model,
            'content_type': content_type,
            'tokens_used': tokens_used,
            'cost': cost,
            'cached': cached,
            'cached_prompt': cached_prompt,
            'generation_time': generation_time,
            'timestamp': datetime.now()
        }
        
        db.collection(settings.COST_TRACKING_DB_COLLECTION).add(cost_doc)
        
        logger.info(f"✅ Tracked cost ${cost:.6f} for {content_type} generation (model: {model})")
        
        return {
            "success": True,
            "cost": round(cost, 6),
            "cached": cached,
            "cached_prompt": cached_prompt
        }
    except Exception as e:
        logger.error(f"Error tracking cost: {e}")
        # Don't fail the request if cost tracking fails
        return {
            "success": False,
            "error": str(e),
            "cost": 0
        }


# Helper functions

def _calculate_generation_cost(
    model: str,
    tokens_used: int,
    cached: bool,
    cached_prompt: bool
) -> float:
    """
    Calculate cost of a generation
    
    Args:
        model: Model name
        tokens_used: Tokens used (if available)
        cached: Whether result was from cache
        cached_prompt: Whether system prompt was cached
    
    Returns:
        Cost in USD
    """
    if cached:
        # Cache hits are free
        return 0.0
    
    # Estimate tokens if not provided (rough approximation)
    if tokens_used == 0:
        # Assume ~1000 input + 500 output for typical generation
        estimated_input = 1000
        estimated_output = 500
    else:
        # Rough split: 60% input, 40% output
        estimated_input = int(tokens_used * 0.6)
        estimated_output = int(tokens_used * 0.4)
    
    # Convert to millions
    input_millions = estimated_input / 1_000_000
    output_millions = estimated_output / 1_000_000
    
    # Calculate based on model
    if 'gemini-2.5' in model.lower() or 'gemini-2.0' in model.lower():
        if cached_prompt:
            # System prompt cached: 90% discount on input
            input_cost = input_millions * settings.GEMINI_2_0_CACHED_COST
        else:
            input_cost = input_millions * settings.GEMINI_2_0_INPUT_COST
        output_cost = output_millions * settings.GEMINI_2_0_OUTPUT_COST
        return input_cost + output_cost
    
    elif 'gemini-2.5' in model.lower():
        if cached_prompt:
            input_cost = input_millions * settings.GEMINI_2_5_CACHED_COST
        else:
            input_cost = input_millions * settings.GEMINI_2_5_INPUT_COST
        output_cost = output_millions * settings.GEMINI_2_5_OUTPUT_COST
        return input_cost + output_cost
    
    elif 'gpt-4o-mini' in model.lower():
        input_cost = input_millions * settings.GPT4O_MINI_INPUT_COST
        output_cost = output_millions * settings.GPT4O_MINI_OUTPUT_COST
        return input_cost + output_cost
    
    else:
        # Unknown model, return 0
        logger.warning(f"Unknown model for cost calculation: {model}")
        return 0.0


def _get_cache_recommendations(stats: Dict[str, Any]) -> List[str]:
    """Generate cache optimization recommendations"""
    recommendations = []
    
    if not stats.get('enabled'):
        recommendations.append("⚠️ Caching is disabled. Enable Redis for cost savings.")
        return recommendations
    
    if not stats.get('available'):
        recommendations.append("❌ Redis is unavailable. Check connection settings.")
        return recommendations
    
    hit_rate = stats.get('hit_rate', 0)
    
    if hit_rate < 20:
        recommendations.append("🔴 Cache hit rate < 20%. Consider increasing TTL or reviewing usage patterns.")
    elif hit_rate < 40:
        recommendations.append("🟡 Cache hit rate < 40%. Good but can improve with longer TTL.")
    else:
        recommendations.append("✅ Cache hit rate > 40%. Excellent performance!")
    
    memory_used = stats.get('memory_used_mb', 0)
    if memory_used > 100:
        recommendations.append("⚠️ Cache using > 100MB memory. Consider clearing old entries.")
    
    return recommendations


def _generate_cost_insights(
    total_cost: float,
    cache_hit_rate: float,
    avg_cost: float,
    costs_by_model: Dict[str, float]
) -> List[str]:
    """Generate cost optimization insights"""
    insights = []
    
    # Cache performance insight
    if cache_hit_rate < 20:
        potential_savings = total_cost * 0.2  # Could save 20% with better caching
        insights.append(f"💰 Improve cache hit rate to save ~${potential_savings:.2f}/month")
    
    # Model usage insight
    gemini_cost = costs_by_model.get('gemini-2.5-flash', costs_by_model.get('gemini-2.0-flash', 0))
    openai_cost = costs_by_model.get('gpt-4o-mini', 0)
    
    if openai_cost > gemini_cost:
        insights.append(f"⚠️ OpenAI costs (${openai_cost:.2f}) exceed Gemini costs. Check fallback frequency.")
    else:
        insights.append(f"✅ Gemini is primary model. Cost-optimized!")
    
    # Average cost insight
    if avg_cost > 0.0005:  # $0.0005 per generation
        insights.append(f"💡 Average cost/generation (${avg_cost:.6f}) is high. Enable prompt caching.")
    else:
        insights.append(f"✅ Cost/generation (${avg_cost:.6f}) is optimized!")
    
    return insights
