"""
Pydantic Schema Models for Gemini Structured Outputs
Uses new google-genai SDK with Pydantic support
"""

from pydantic import BaseModel, Field
from typing import List, Optional, Literal


# ==================== SOCIAL MEDIA SCHEMAS ====================

class SocialCaption(BaseModel):
    """Individual social media caption variation"""
    variation: int = Field(description="Variation number (1-5)")
    text: str = Field(description="The caption text with emojis and formatting")
    length: int = Field(description="Character count of the caption text")


class SocialMediaOutput(BaseModel):
    """
    Social media content generation output
    Supports LinkedIn, Twitter, Instagram, TikTok, Facebook
    """
    captions: List[SocialCaption] = Field(
        description="3 unique caption variations with different angles and hooks",
        min_length=3,
        max_length=3
    )
    hashtags: List[str] = Field(
        description="Relevant hashtags for the platform (3-15 items). Use # prefix.",
        default=[]
    )
    emojiSuggestions: List[str] = Field(
        description="Suggested emojis that fit the platform style (5-10 items)",
        default=[]
    )
    engagementTips: str = Field(
        description="2-3 specific tips for maximizing engagement on this platform"
    )


# ==================== BLOG POST SCHEMAS ====================

class BlogSection(BaseModel):
    """Individual blog section with heading and content"""
    heading: str = Field(description="H2 or H3 heading for the section")
    content: str = Field(description="Section content with proper paragraphs")


class BlogPostOutput(BaseModel):
    """
    Blog post generation output with SEO optimization
    """
    title: str = Field(
        description="SEO-optimized blog title with primary keyword (max 60 characters)"
    )
    metaDescription: str = Field(
        description="SEO meta description, exactly 155-160 characters"
    )
    introduction: str = Field(
        description="Engaging introduction (150-200 words) with hook and keyword"
    )
    sections: List[BlogSection] = Field(
        description="Main content sections with H2/H3 headings"
    )
    conclusion: str = Field(
        description="Strong conclusion (100-150 words) with CTA"
    )
    wordCount: int = Field(
        description="Actual word count of the entire content"
    )


# ==================== EMAIL CAMPAIGN SCHEMAS ====================

class EmailCampaignOutput(BaseModel):
    """
    Email campaign generation output
    """
    subject: str = Field(
        description="Compelling email subject line (40-60 characters)"
    )
    preheader: str = Field(
        description="Preview text shown in inbox (40-100 characters)"
    )
    body: str = Field(
        description="Email body with proper formatting and paragraphs"
    )
    callToAction: str = Field(
        description="Clear call-to-action button text or link"
    )


# ==================== VIDEO SCRIPT SCHEMAS ====================

class VideoSection(BaseModel):
    """Individual video script section"""
    sectionType: Literal["hook", "introduction", "main_point", "transition", "call_to_action", "outro"] = Field(
        description="Type of section in the video script"
    )
    timestamp: str = Field(
        description="Approximate timestamp (e.g., '0:00-0:15')"
    )
    script: str = Field(
        description="Script text for this section"
    )
    visualNotes: Optional[str] = Field(
        description="Optional notes about visuals or B-roll",
        default=None
    )


class VideoScriptOutput(BaseModel):
    """
    Video script generation output
    """
    title: str = Field(
        description="Video title optimized for platform"
    )
    description: str = Field(
        description="Video description with timestamps and keywords"
    )
    sections: List[VideoSection] = Field(
        description="Script sections with timestamps and visual notes"
    )
    totalDuration: str = Field(
        description="Estimated total video duration (e.g., '3:45')"
    )
    hashtags: List[str] = Field(
        description="10-20 relevant hashtags optimized for the platform (use # prefix)",
        default=[]
    )
    recommendedMusic: List[str] = Field(
        description="3-5 music suggestions with genre and mood (e.g., 'Upbeat electronic', 'Calm acoustic guitar')",
        default=[]
    )
    retentionHooks: List[str] = Field(
        description="3-5 pattern interrupts or retention hooks to keep viewers engaged throughout the video",
        default=[]
    )


# ==================== HELPER FUNCTIONS ====================

def get_social_media_schema():
    """Get social media output schema for Gemini"""
    return SocialMediaOutput.model_json_schema()


def get_blog_post_schema():
    """Get blog post output schema for Gemini"""
    return BlogPostOutput.model_json_schema()


def get_email_campaign_schema():
    """Get email campaign output schema for Gemini"""
    return EmailCampaignOutput.model_json_schema()


def get_video_script_schema():
    """Get video script output schema for Gemini"""
    return VideoScriptOutput.model_json_schema()
