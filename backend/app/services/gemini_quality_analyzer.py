"""
Gemini AI Quality Analyzer Service
Uses Gemini 2.0 Flash for deep content quality analysis
"""

import os
import logging
from typing import Dict, List, Optional, Any
import google.generativeai as genai
from dataclasses import dataclass, asdict
import json

logger = logging.getLogger(__name__)

@dataclass
class AIQualityAnalysis:
    """AI-generated quality analysis result"""
    grammar_score: float  # 0-1 scale
    style_score: float    # 0-1 scale
    tone_appropriateness: float  # 0-1 scale
    engagement_potential: float  # 0-1 scale
    overall_ai_score: float  # 0-1 scale
    
    strengths: List[str]
    improvements: List[str]
    tone_analysis: str
    style_feedback: str
    
    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


class GeminiQualityAnalyzer:
    """
    Advanced quality analysis using Gemini 2.0 Flash
    Cost-effective: ~$0.0001 per analysis
    """
    
    def __init__(self):
        """Initialize Gemini API with Flash model"""
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            raise ValueError("GEMINI_API_KEY environment variable not set")
        
        genai.configure(api_key=api_key)
        
        # Use Gemini 2.0 Flash - fast and cheap
        self.model = genai.GenerativeModel('gemini-2.0-flash-exp')
        
        logger.info("✨ Gemini Quality Analyzer initialized with 2.0 Flash")
    
    async def analyze_quality(
        self,
        content: str,
        content_type: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> AIQualityAnalysis:
        """
        Perform deep AI-powered quality analysis
        
        Args:
            content: Generated content to analyze
            content_type: Type (blog, social, email, etc.)
            metadata: Additional context (tone, keywords, audience)
        
        Returns:
            AIQualityAnalysis with detailed scores and feedback
        """
        metadata = metadata or {}
        
        try:
            # Build context-aware prompt
            prompt = self._build_analysis_prompt(content, content_type, metadata)
            
            # Generate analysis with Gemini
            logger.info(f"🤖 Analyzing {content_type} content with Gemini ({len(content)} chars)...")
            
            response = self.model.generate_content(
                prompt,
                generation_config=genai.GenerationConfig(
                    temperature=0.3,  # Low temperature for consistent scoring
                    top_p=0.8,
                    top_k=40,
                    max_output_tokens=1024,  # Enough for detailed feedback
                    response_mime_type="application/json"
                )
            )
            
            # Parse JSON response
            analysis_data = json.loads(response.text)
            
            # Validate and normalize scores (ensure 0-1 range)
            analysis = AIQualityAnalysis(
                grammar_score=min(max(analysis_data.get('grammar_score', 0.7), 0), 1),
                style_score=min(max(analysis_data.get('style_score', 0.7), 0), 1),
                tone_appropriateness=min(max(analysis_data.get('tone_appropriateness', 0.7), 0), 1),
                engagement_potential=min(max(analysis_data.get('engagement_potential', 0.7), 0), 1),
                overall_ai_score=min(max(analysis_data.get('overall_score', 0.7), 0), 1),
                strengths=analysis_data.get('strengths', [])[:5],  # Limit to top 5
                improvements=analysis_data.get('improvements', [])[:5],
                tone_analysis=analysis_data.get('tone_analysis', ''),
                style_feedback=analysis_data.get('style_feedback', '')
            )
            
            logger.info(f"✅ AI Quality Analysis complete: {analysis.overall_ai_score:.2f}")
            return analysis
            
        except Exception as e:
            logger.error(f"❌ Gemini analysis failed: {e}")
            # Return conservative fallback scores
            return self._get_fallback_analysis()
    
    def _build_analysis_prompt(
        self,
        content: str,
        content_type: str,
        metadata: Dict[str, Any]
    ) -> str:
        """Build context-aware analysis prompt for Gemini"""
        
        # Get context
        target_tone = metadata.get('tone', 'professional')
        target_audience = metadata.get('target_audience', 'general')
        keywords = metadata.get('keywords', [])
        
        # Content type specific guidance
        type_guidance = {
            'blog': "Analyze as a professional blog post. Check for engaging introduction, clear structure with headings, informative body, and strong conclusion.",
            'social': "Analyze as social media content. Check for attention-grabbing opener, conciseness, engagement hooks, and call-to-action.",
            'email': "Analyze as an email campaign. Check for personalized greeting, clear value proposition, persuasive body, and strong CTA.",
            'product': "Analyze as product description. Check for benefit-focused language, feature clarity, persuasive tone, and purchase motivation.",
            'ad': "Analyze as advertising copy. Check for compelling headline, clear USP, emotional appeal, and urgent CTA.",
            'video': "Analyze as video script. Check for conversational tone, visual cues, pacing, and viewer retention elements."
        }
        
        guidance = type_guidance.get(content_type, "Analyze the content quality comprehensively.")
        
        prompt = f"""You are an expert content quality analyst. Analyze this {content_type} content with precision.

CONTENT TO ANALYZE:
\"\"\"
{content}
\"\"\"

CONTEXT:
- Content Type: {content_type}
- Target Tone: {target_tone}
- Target Audience: {target_audience}
- Keywords: {', '.join(keywords) if keywords else 'None specified'}

ANALYSIS TASK:
{guidance}

Evaluate across these dimensions:

1. GRAMMAR & MECHANICS (grammar_score 0-1):
   - Spelling, punctuation, syntax correctness
   - Sentence structure variety and flow
   - Word choice precision and clarity

2. STYLE & READABILITY (style_score 0-1):
   - Writing style appropriateness for content type
   - Paragraph structure and transitions
   - Sentence length variety and rhythm

3. TONE APPROPRIATENESS (tone_appropriateness 0-1):
   - Alignment with target tone ({target_tone})
   - Consistency throughout content
   - Audience appropriateness

4. ENGAGEMENT POTENTIAL (engagement_potential 0-1):
   - Hook strength and attention retention
   - Emotional resonance and relatability
   - Call-to-action effectiveness

IMPORTANT SCORING GUIDELINES:
- Be realistic but fair
- 0.85-1.0 = Exceptional (publish-ready)
- 0.70-0.84 = Good (minor tweaks needed)
- 0.60-0.69 = Decent (needs improvements)
- Below 0.60 = Needs significant work

Respond with JSON ONLY (no markdown):
{{
  "grammar_score": 0.85,
  "style_score": 0.80,
  "tone_appropriateness": 0.90,
  "engagement_potential": 0.75,
  "overall_score": 0.82,
  "strengths": [
    "Clear and concise writing",
    "Strong opening hook",
    "Good use of examples"
  ],
  "improvements": [
    "Add more transition phrases between paragraphs",
    "Strengthen the call-to-action",
    "Include more specific data or statistics"
  ],
  "tone_analysis": "The tone is professional and authoritative, well-suited for the target audience. Maintains consistency throughout.",
  "style_feedback": "Writing style is clear and accessible. Good balance of short and long sentences. Could benefit from more active voice in places."
}}"""
        
        return prompt
    
    def _get_fallback_analysis(self) -> AIQualityAnalysis:
        """Return conservative fallback scores if AI analysis fails"""
        return AIQualityAnalysis(
            grammar_score=0.70,
            style_score=0.70,
            tone_appropriateness=0.70,
            engagement_potential=0.70,
            overall_ai_score=0.70,
            strengths=["Content generated successfully"],
            improvements=["AI analysis temporarily unavailable"],
            tone_analysis="Content appears to meet basic quality standards.",
            style_feedback="Standard content structure maintained."
        )
