#!/usr/bin/env python3
"""
Test fact-checking endpoint directly
Bypasses authentication for debugging
"""

import asyncio
import json
from app.services.openai_service import OpenAIService
from app.services.smart_fact_checker import SmartFactChecker
from dotenv import load_dotenv

load_dotenv()

async def test_fact_checking():
    """Test the complete fact-checking flow"""
    
    print("\n" + "="*60)
    print("FACT-CHECKING END-TO-END TEST")
    print("="*60)
    
    # Initialize services
    openai_service = OpenAIService()
    
    print("\n1️⃣  Generating blog content...")
    print("-" * 60)
    
    # Generate blog post with factual topic
    ai_result = await openai_service.generate_blog_post(
        topic="NASA Mars Perseverance Rover Mission 2021",
        keywords=["NASA", "Mars", "Perseverance", "rover", "2021"],
        tone="professional",
        word_count=600,
        sections=None,
        user_tier="free",
        user_id="test_user",
        target_audience="space enthusiasts",
        writing_style=None,
        include_examples=True
    )
    
    blog_output = ai_result['output']
    content_text = blog_output.get('content', '')
    
    print(f"✅ Generated blog post:")
    print(f"   Title: {blog_output.get('title', 'N/A')}")
    print(f"   Word count: {blog_output.get('wordCount', 0)}")
    print(f"   Content length: {len(content_text)} chars")
    print(f"   Content preview: {content_text[:200]}...")
    
    print("\n2️⃣  Running fact-checker on generated content...")
    print("-" * 60)
    
    # Run fact-checker
    fact_check_result = await openai_service.fact_checker.check_facts(
        content=content_text,
        content_type='blog',
        enable_fact_check=True
    )
    
    print(f"\n✅ Fact-check results:")
    print(f"   Checked: {fact_check_result.checked}")
    print(f"   Claims found: {fact_check_result.claims_found}")
    print(f"   Claims verified: {fact_check_result.claims_verified}")
    print(f"   Overall confidence: {fact_check_result.overall_confidence:.2f}")
    print(f"   Verification time: {fact_check_result.verification_time:.2f}s")
    print(f"   Total searches used: {fact_check_result.total_searches_used}")
    
    if fact_check_result.claims:
        print(f"\n📊 Verified claims:")
        for i, claim in enumerate(fact_check_result.claims, 1):
            print(f"\n   Claim {i}:")
            print(f"   ├─ Text: {claim.claim}")
            print(f"   ├─ Verified: {claim.verified}")
            print(f"   ├─ Confidence: {claim.confidence:.2f}")
            print(f"   ├─ Evidence: {claim.evidence[:100]}...")
            print(f"   └─ Sources: {len(claim.sources)} sources")
            for j, source in enumerate(claim.sources[:2], 1):
                print(f"      {j}. [{source.authority_level}] {source.domain}")
                print(f"         {source.url[:80]}...")
    else:
        print("\n⚠️  NO CLAIMS EXTRACTED!")
        print("   This is the root cause of the issue.")
    
    print("\n" + "="*60)
    print("TEST COMPLETE")
    print("="*60 + "\n")

if __name__ == "__main__":
    asyncio.run(test_fact_checking())
