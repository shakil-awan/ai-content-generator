"""
Prompt Enhancement System
Converts rough user prompts into optimized API prompts for better AI responses

Based on best practices from:
- Google Gemini Prompt Engineering Guide (Nov 2025)
- OpenAI Prompt Engineering Guide
- Real-world testing with content generation

Last Updated: November 25, 2025
"""

from typing import Dict, Any, List, Optional
from enum import Enum


class ContentType(Enum):
    """Content types supported by the system"""
    BLOG_POST = "blog"
    SOCIAL_MEDIA = "social"
    EMAIL = "email"
    PRODUCT_DESC = "product"
    AD_COPY = "ad"
    VIDEO_SCRIPT = "video"


class PromptEnhancer:
    """
    Enhances rough user prompts with best practices for AI models
    
    Key Principles (from Gemini/OpenAI guidelines):
    1. Be precise and direct
    2. Use clear structure with XML/Markdown tags
    3. Add context and constraints
    4. Specify output format
    5. Include few-shot examples when beneficial
    6. Break complex tasks into components
    """
    
    def __init__(self):
        self.system_prompts = self._load_system_prompts()
        self.templates = self._load_templates()
    
    def enhance_prompt(
        self,
        user_prompt: str,
        content_type: str,
        tone: str = "professional",
        word_count: Optional[int] = None,
        platform: Optional[str] = None,
        additional_context: Optional[Dict[str, Any]] = None,
        **kwargs  # Accept additional keyword arguments
    ) -> Dict[str, str]:
        """
        Convert rough user prompt into optimized API prompt
        
        Args:
            user_prompt: Raw user input (e.g., "write about AI")
            content_type: Type of content (blog, social, email, etc.)
            tone: Desired tone (professional, casual, creative, etc.)
            word_count: Target word count
            platform: Social media platform (if applicable)
            additional_context: Extra requirements
            **kwargs: Additional parameters like target_audience, campaign_goal, etc.
            
        Returns:
            Dict with 'system_prompt' and 'user_prompt'
        """
        # Merge kwargs into additional_context
        if additional_context is None:
            additional_context = {}
        additional_context.update(kwargs)
        
        # Get base template
        template = self.templates.get(content_type, self.templates["default"])
        system_prompt = self.system_prompts.get(content_type, self.system_prompts["default"])
        
        # Enhance based on content type
        if content_type == "blog":
            enhanced = self._enhance_blog_prompt(user_prompt, tone, word_count, additional_context)
        elif content_type == "social":
            enhanced = self._enhance_social_prompt(user_prompt, tone, platform, additional_context)
        elif content_type == "email":
            enhanced = self._enhance_email_prompt(user_prompt, tone, additional_context)
        elif content_type == "product":
            enhanced = self._enhance_product_prompt(user_prompt, tone, additional_context)
        elif content_type == "ad":
            enhanced = self._enhance_ad_prompt(user_prompt, tone, additional_context)
        elif content_type == "video":
            enhanced = self._enhance_video_prompt(user_prompt, tone, additional_context)
        else:
            enhanced = user_prompt
        
        return {
            "system_prompt": system_prompt,
            "user_prompt": enhanced
        }
    
    def _enhance_blog_prompt(
        self,
        user_prompt: str,
        tone: str,
        word_count: Optional[int],
        context: Optional[Dict[str, Any]]
    ) -> str:
        """Enhance blog post prompts with structure and detail"""
        
        word_count = word_count or 3000
        keywords = context.get("keywords", []) if context else []
        sections = context.get("sections", []) if context else []
        
        enhanced = f"""<task>
Generate a comprehensive, SEO-optimized blog post on the following topic:
</task>

<topic>
{user_prompt}
</topic>

<requirements>
- Tone: {tone}
- Target length: {word_count} words
- Writing style: Engaging, informative, and naturally flowing
{"- Keywords to naturally incorporate: " + ", ".join(keywords) if keywords else ""}
{"- Required sections: " + ", ".join(sections) if sections else "- Structure: Introduction, 3-5 main sections, Conclusion"}
</requirements>

<output_format>
Return as JSON:
{{
  "title": "SEO-optimized title with primary keyword",
  "metaDescription": "Compelling 150-160 char meta description",
  "content": "Full article in markdown format",
  "headings": ["List of H2 headings used"],
  "wordCount": actual_word_count
}}
</output_format>

<guidelines>
1. Start with a strong hook in the introduction
2. Use examples, data, and real-world applications
3. Include transition phrases between sections
4. End with actionable takeaways
5. Maintain consistent tone throughout
6. Ensure natural keyword placement (avoid stuffing)
</guidelines>"""
        
        return enhanced
    
    def _enhance_social_prompt(
        self,
        user_prompt: str,
        tone: str,
        platform: Optional[str],
        context: Optional[Dict[str, Any]]
    ) -> str:
        """Enhance social media prompts with platform-specific optimization"""
        
        platform = platform or "linkedin"
        include_cta = context.get("include_cta", True) if context else True
        include_hashtags = context.get("include_hashtags", True) if context else True
        target_audience = context.get("target_audience", "general audience") if context else "general audience"
        
        # Platform-specific constraints
        platform_specs = {
            "linkedin": {"max_chars": 1300, "style": "professional, thought leadership"},
            "twitter": {"max_chars": 280, "style": "snappy, conversational"},
            "instagram": {"max_chars": 2200, "style": "engaging, storytelling"},
            "tiktok": {"max_chars": 300, "style": "casual, trendy, youth-focused"}
        }
        
        spec = platform_specs.get(platform.lower(), platform_specs["linkedin"])
        
        enhanced = f"""<task>
Create engaging {platform} captions for the following content:
</task>

<content>
{user_prompt}
</content>

<requirements>
- Platform: {platform} (max {spec['max_chars']} characters)
- Style: {spec['style']}
- Tone: {tone}
- Target audience: {target_audience}
- Include CTA: {include_cta}
- Include hashtags: {include_hashtags}
</requirements>

<output_format>
Return as JSON:
{{
  "captions": [
    {{"variation": 1, "text": "caption text", "length": char_count}},
    {{"variation": 2, "text": "caption text", "length": char_count}},
    {{"variation": 3, "text": "caption text", "length": char_count}},
    {{"variation": 4, "text": "caption text", "length": char_count}},
    {{"variation": 5, "text": "caption text", "length": char_count}}
  ],
  "hashtags": ["#tag1", "#tag2", ...] (15-20 relevant, trending hashtags),
  "emojiSuggestions": ["emoji1", "emoji2", ...],
  "engagementTips": "Brief tips for maximizing engagement"
}}
</output_format>

<guidelines>
1. Hook the reader in the first line
2. Use appropriate emojis naturally
3. Include question or CTA to drive engagement
4. Vary caption styles (question, story, tip, fact, quote)
5. Ensure each variation has a unique angle
</guidelines>"""
        
        return enhanced
    
    def _enhance_email_prompt(
        self,
        user_prompt: str,
        tone: str,
        context: Optional[Dict[str, Any]]
    ) -> str:
        """Enhance email campaign prompts"""
        
        campaign_type = context.get("campaign_type", "newsletter") if context else "newsletter"
        goal = context.get("goal", "engagement") if context else "engagement"
        
        enhanced = f"""<task>
Create a {campaign_type} email campaign:
</task>

<content>
{user_prompt}
</content>

<requirements>
- Campaign type: {campaign_type}
- Tone: {tone}
- Goal: {goal}
</requirements>

<output_format>
Return as JSON:
{{
  "subjectLines": ["3 variations for A/B testing"],
  "previewText": "Compelling preview text (40-90 chars)",
  "bodyIntro": "Opening paragraph",
  "bodyMain": "Main content with sections",
  "cta": "Call-to-action text",
  "ctaButtonText": ["3 CTA button variations"],
  "closing": "Closing message",
  "bestSendTime": "Recommended send time with reasoning"
}}
</output_format>

<guidelines>
1. Subject line: Create curiosity, avoid spam triggers
2. Preview text: Extend subject line intrigue
3. Intro: Personalize and hook immediately
4. Body: Provide value before asking
5. CTA: Clear, action-oriented, benefit-focused
6. Closing: Warm, human, branded
</guidelines>"""
        
        return enhanced
    
    def _enhance_product_prompt(
        self,
        user_prompt: str,
        tone: str,
        context: Optional[Dict[str, Any]]
    ) -> str:
        """Enhance product description prompts"""
        
        platform = context.get("platform", "shopify") if context else "shopify"
        
        enhanced = f"""<task>
Create SEO-optimized product description for {platform}:
</task>

<product_info>
{user_prompt}
</product_info>

<requirements>
- Platform: {platform}
- Tone: {tone}
- Focus: Benefits over features
</requirements>

<output_format>
Return as JSON:
{{
  "shortDescription": "Compelling 100-word summary",
  "longDescription": "Detailed 300-word description",
  "bulletPoints": ["5-7 key benefits with emojis"],
  "seoTitle": "60-char SEO-optimized title",
  "metaDescription": "160-char meta description",
  "tags": ["Relevant category/search tags"]
}}
</output_format>

<guidelines>
1. Lead with primary benefit
2. Use sensory language
3. Address pain points solution provides
4. Include social proof elements (if available)
5. Create urgency subtly
6. End with clear next step
</guidelines>"""
        
        return enhanced
    
    def _enhance_ad_prompt(
        self,
        user_prompt: str,
        tone: str,
        context: Optional[Dict[str, Any]]
    ) -> str:
        """Enhance ad copy prompts"""
        
        platform = context.get("platform", "google") if context else "google"
        goal = context.get("goal", "conversion") if context else "conversion"
        
        enhanced = f"""<task>
Create high-converting {platform} ad copy:
</task>

<product_service>
{user_prompt}
</product_service>

<requirements>
- Platform: {platform}
- Goal: {goal}
- Tone: {tone}
</requirements>

<output_format>
Return as JSON:
{{
  "adVariations": [
    {{
      "headline": "3 variations (30 chars max)",
      "description": "Ad text (90 chars max)",
      "cta": "3 CTA variations",
      "uniqueAngle": "What makes this version unique"
    }},
    // 2 more variations
  ],
  "estimatedCTR": "Expected CTR with reasoning",
  "emotionalTriggers": ["List of triggers used"],
  "targetAudience": "Best audience for each variation"
}}
</output_format>

<guidelines>
1. Headlines: Clear benefit + urgency
2. Description: Problem → Solution → CTA
3. Use power words (proven, guaranteed, limited)
4. Address objections preemptively
5. Test emotional vs rational appeals
6. Include numbers/statistics when possible
</guidelines>"""
        
        return enhanced
    
    def _enhance_video_prompt(
        self,
        user_prompt: str,
        tone: str,
        context: Optional[Dict[str, Any]]
    ) -> str:
        """Enhance video script prompts"""
        
        platform = context.get("platform", "youtube") if context else "youtube"
        duration = context.get("duration", 300) if context else 300  # 5 minutes default
        
        enhanced = f"""<task>
Create engaging {platform} video script:
</task>

<topic>
{user_prompt}
</topic>

<requirements>
- Platform: {platform}
- Duration: {duration} seconds
- Tone: {tone}
- Optimize for retention
</requirements>

<output_format>
Return as JSON:
{{
  "hook": "First 5 seconds (must grab attention)",
  "intro": "Introduction with timestamp",
  "mainSections": [
    {{
      "timestamp": "00:00",
      "title": "Section title",
      "script": "Spoken content",
      "brollSuggestions": "Visual suggestions",
      "patternInterrupt": "Retention hook"
    }}
  ],
  "cta": "Call-to-action script",
  "outro": "Closing with timestamp",
  "thumbnailTitles": ["3 thumbnail title options"],
  "videoDescription": "YouTube description with timestamps",
  "hashtags": ["15-20 relevant hashtags"],
  "retentionScore": "Estimated average view duration %"
}}
</output_format>

<guidelines>
1. Hook: Tease outcome, create curiosity, or shock
2. Pattern interrupts every 30 seconds
3. Use open loops (promise, deliver later)
4. Vary pacing: Fast for exciting, slow for important
5. Include viewer participation prompts
6. Strong CTA before outro
7. Timestamps for key moments
</guidelines>"""
        
        return enhanced
    
    def _load_system_prompts(self) -> Dict[str, str]:
        """Load system prompts for each content type"""
        return {
            "blog": """You are an expert SEO content writer specializing in comprehensive, engaging blog posts. 
Your writing is informative, well-structured, and optimized for search engines while remaining highly readable. 
You incorporate examples, data, and real-world applications naturally. Always return valid JSON.""",
            
            "social": """You are a social media expert who creates viral, engaging content across all platforms.
You understand platform algorithms, audience psychology, and trending formats.
You craft captions that drive engagement, shares, and conversions. Always return valid JSON.""",
            
            "email": """You are an email marketing specialist with expertise in conversion optimization.
You write compelling subject lines, engaging copy, and persuasive CTAs.
You understand deliverability best practices and A/B testing. Always return valid JSON.""",
            
            "product": """You are an e-commerce copywriter specializing in product descriptions that sell.
You highlight benefits over features, use sensory language, and create desire.
You optimize for both SEO and conversion. Always return valid JSON.""",
            
            "ad": """You are a direct response copywriter expert in paid advertising across all platforms.
You understand consumer psychology, persuasion principles, and conversion optimization.
You create high-CTR ads that drive action. Always return valid JSON.""",
            
            "video": """You are a video script writer specializing in engaging, retention-optimized content.
You understand platform algorithms, viewer psychology, and pacing.
You create scripts that hook viewers and maintain engagement throughout. Always return valid JSON.""",
            
            "default": """You are an expert content creator skilled in all forms of writing.
You adapt your style based on requirements while maintaining quality and engagement.
You always follow instructions precisely and return structured output. Always return valid JSON."""
        }
    
    def _load_templates(self) -> Dict[str, str]:
        """Load prompt templates (for future expansion)"""
        return {
            "default": "Create high-quality {content_type} content based on: {user_input}"
        }


def improve_prompt(
    user_prompt: str,
    content_type: str,
    **kwargs
) -> str:
    """
    Quick function to enhance any prompt - returns enhanced user prompt string
    
    Usage:
        enhanced = improve_prompt(
            user_prompt="write about AI",
            content_type="blog",
            tone="professional",
            word_count=3000
        )
        
        # Returns enhanced string ready to use with API
    """
    enhancer = PromptEnhancer()
    result = enhancer.enhance_prompt(user_prompt, content_type, **kwargs)
    # Return only the enhanced user_prompt string for easy API integration
    return result['user_prompt']


def get_enhanced_prompts(
    user_prompt: str,
    content_type: str,
    **kwargs
) -> Dict[str, str]:
    """
    Get both system and user prompts (for advanced usage)
    
    Returns:
        Dict with 'system_prompt' and 'user_prompt'
    """
    enhancer = PromptEnhancer()
    return enhancer.enhance_prompt(user_prompt, content_type, **kwargs)


# Example usage
if __name__ == "__main__":
    # Test blog enhancement
    rough_prompt = "write about machine learning"
    enhanced = improve_prompt(
        user_prompt=rough_prompt,
        content_type="blog",
        tone="professional",
        word_count=3000,
        additional_context={"keywords": ["AI", "ML", "algorithms"]}
    )
    
    print("SYSTEM PROMPT:")
    print(enhanced["system_prompt"])
    print("\n" + "="*80 + "\n")
    print("USER PROMPT:")
    print(enhanced["user_prompt"])
