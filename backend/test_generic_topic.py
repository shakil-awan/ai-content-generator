#!/usr/bin/env python3
"""
Test fact-checking with generic topic (like user's actual case)
"""

import asyncio
import json
from app.services.openai_service import OpenAIService
from dotenv import load_dotenv

load_dotenv()

async def test_generic_topic():
    """Test with a generic topic like user had"""
    
    print("\n" + "="*70)
    print("TEST: Generic Topic (AI for developers) - WITH fact-check enabled")
    print("="*70)
    
    openai_service = OpenAIService()
    
    print("\n🧪 Generating blog with generic topic...")
    print("-" * 70)
    
    # Generate blog with generic topic AND enable_fact_check=True
    ai_result = await openai_service.generate_blog_post(
        topic="AI for developers",
        keywords=["ai", "developers", "programming"],
        tone="professional",
        word_count=500,
        sections=None,
        user_tier="free",
        user_id="test_user",
        target_audience="developers",
        writing_style=None,
        include_examples=True,
        enable_fact_check=True  # THIS IS THE KEY!
    )
    
    blog_output = ai_result['output']
    content_text = blog_output.get('content', '')
    
    print(f"✅ Generated blog:")
    print(f"   Title: {blog_output.get('title', 'N/A')}")
    print(f"   Word count: {blog_output.get('wordCount', 0)}")
    print(f"   Content preview: {content_text[:300]}...")
    
    print("\n🔍 Running fact-checker...")
    print("-" * 70)
    
    fact_check_result = await openai_service.fact_checker.check_facts(
        content=content_text,
        content_type='blog',
        enable_fact_check=True
    )
    
    print(f"\n📊 Results:")
    print(f"   Claims found: {fact_check_result.claims_found}")
    print(f"   Claims verified: {fact_check_result.claims_verified}")
    
    if fact_check_result.claims:
        print(f"\n✅ SUCCESS! Found {len(fact_check_result.claims)} verifiable claims:")
        for i, claim in enumerate(fact_check_result.claims, 1):
            print(f"   {i}. {claim.claim[:80]}...")
    else:
        print(f"\n❌ NO CLAIMS EXTRACTED - This was the original issue!")
    
    print("\n" + "="*70)
    
    # Now test WITHOUT enable_fact_check flag
    print("\n" + "="*70)
    print("TEST: Same topic WITHOUT fact-check hint to AI")
    print("="*70)
    
    print("\n🧪 Generating blog WITHOUT factual requirement...")
    print("-" * 70)
    
    ai_result2 = await openai_service.generate_blog_post(
        topic="AI for developers",
        keywords=["ai", "developers", "programming"],
        tone="professional",
        word_count=500,
        sections=None,
        user_tier="free",
        user_id="test_user",
        target_audience="developers",
        writing_style=None,
        include_examples=True,
        enable_fact_check=False  # OLD BEHAVIOR
    )
    
    blog_output2 = ai_result2['output']
    content_text2 = blog_output2.get('content', '')
    
    print(f"✅ Generated blog:")
    print(f"   Title: {blog_output2.get('title', 'N/A')}")
    print(f"   Content preview: {content_text2[:300]}...")
    
    print("\n🔍 Running fact-checker on opinion-based content...")
    print("-" * 70)
    
    fact_check_result2 = await openai_service.fact_checker.check_facts(
        content=content_text2,
        content_type='blog',
        enable_fact_check=True
    )
    
    print(f"\n📊 Results:")
    print(f"   Claims found: {fact_check_result2.claims_found}")
    print(f"   Claims verified: {fact_check_result2.claims_verified}")
    
    if fact_check_result2.claims:
        print(f"\n   Found {len(fact_check_result2.claims)} claims")
    else:
        print(f"\n   ⚠️  As expected: opinion-based content has no verifiable claims")
    
    print("\n" + "="*70)
    print("COMPARISON:")
    print(f"  WITH fact-check hint: {fact_check_result.claims_found} claims")
    print(f"  WITHOUT fact-check hint: {fact_check_result2.claims_found} claims")
    print("="*70 + "\n")

if __name__ == "__main__":
    asyncio.run(test_generic_topic())
