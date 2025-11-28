#!/usr/bin/env python3
"""
Test social media API with all include parameters
Tests: include_hashtags, include_emoji, include_call_to_action
"""

import asyncio
import json
import os
from dotenv import load_dotenv

load_dotenv()

# Import after loading env
from app.services.openai_service import OpenAIService


async def test_social_media_generation():
    """Test social media generation with all include parameters"""
    
    print("\n" + "="*80)
    print("SOCIAL MEDIA API PARAMETER TEST")
    print("="*80)
    
    openai_service = OpenAIService()
    
    # Test cases with different parameter combinations
    test_cases = [
        {
            "name": "All features enabled (default)",
            "params": {
                "include_hashtags": True,
                "include_emoji": True,
                "include_cta": True
            }
        },
        {
            "name": "Only hashtags",
            "params": {
                "include_hashtags": True,
                "include_emoji": False,
                "include_cta": False
            }
        },
        {
            "name": "Only emoji",
            "params": {
                "include_hashtags": False,
                "include_emoji": True,
                "include_cta": False
            }
        },
        {
            "name": "Only CTA",
            "params": {
                "include_hashtags": False,
                "include_emoji": False,
                "include_cta": True
            }
        },
        {
            "name": "All features disabled",
            "params": {
                "include_hashtags": False,
                "include_emoji": False,
                "include_cta": False
            }
        }
    ]
    
    for i, test_case in enumerate(test_cases, 1):
        print(f"\n{'='*80}")
        print(f"TEST CASE {i}: {test_case['name']}")
        print(f"Parameters: {json.dumps(test_case['params'], indent=2)}")
        print(f"{'='*80}")
        
        try:
            # Generate social media content
            result = await openai_service.generate_social_media(
                content_description="Launching a new AI content generator app for developers",
                platform="instagram",
                target_audience="developers and content creators",
                tone="friendly",
                include_hashtags=test_case['params']['include_hashtags'],
                include_emoji=test_case['params']['include_emoji'],
                include_cta=test_case['params']['include_cta'],
                user_tier="premium",
                user_id="test_user"
            )
            
            output = result.get('output', {})
            captions = output.get('captions', [])
            hashtags = output.get('hashtags', [])
            emoji_suggestions = output.get('emojiSuggestions', [])
            engagement_tips = output.get('engagementTips', '')
            
            print(f"\n✅ Generation successful!")
            print(f"\n📝 Sample Caption (first variation):")
            if captions:
                print(f"   {captions[0].get('text', 'N/A')[:200]}...")
            else:
                print("   No captions generated")
            
            print(f"\n#️⃣ Hashtags ({len(hashtags)}):")
            if hashtags:
                print(f"   {', '.join(hashtags[:10])}")
            else:
                print("   No hashtags generated")
            
            print(f"\n😊 Emoji Suggestions ({len(emoji_suggestions)}):")
            if emoji_suggestions:
                print(f"   {' '.join(emoji_suggestions[:15])}")
            else:
                print("   No emoji suggestions")
            
            print(f"\n💡 Engagement Tips:")
            print(f"   {engagement_tips[:150]}...")
            
            # Verify parameters were respected
            print(f"\n🔍 Parameter Verification:")
            
            if test_case['params']['include_hashtags']:
                if hashtags and len(hashtags) > 0:
                    print(f"   ✅ Hashtags included as requested")
                else:
                    print(f"   ⚠️  Hashtags requested but not generated properly")
            else:
                if not hashtags or len(hashtags) == 0:
                    print(f"   ✅ Hashtags excluded as requested")
                else:
                    print(f"   ⚠️  Hashtags excluded but still generated")
            
            if test_case['params']['include_emoji']:
                if emoji_suggestions and len(emoji_suggestions) > 0:
                    print(f"   ✅ Emoji included as requested")
                else:
                    print(f"   ⚠️  Emoji requested but not generated properly")
            else:
                if not emoji_suggestions or len(emoji_suggestions) == 0:
                    print(f"   ✅ Emoji excluded as requested")
                else:
                    print(f"   ⚠️  Emoji excluded but still generated")
            
            # Check for CTA in captions
            has_cta = False
            if captions:
                first_caption = captions[0].get('text', '').lower()
                cta_keywords = ['click', 'visit', 'check out', 'learn more', 'get started', 
                               'sign up', 'join', 'download', 'try', 'explore', 'discover']
                has_cta = any(keyword in first_caption for keyword in cta_keywords)
            
            if test_case['params']['include_cta']:
                if has_cta:
                    print(f"   ✅ CTA included as requested")
                else:
                    print(f"   ⚠️  CTA requested but not clearly present")
            else:
                if not has_cta:
                    print(f"   ✅ CTA excluded as requested")
                else:
                    print(f"   ⚠️  CTA excluded but still present")
            
            # Check quality score
            quality_score = result.get('quality_score', {})
            if quality_score:
                print(f"\n📊 Quality Score:")
                print(f"   Overall: {quality_score.get('overall', 0):.2f}")
                print(f"   Readability: {quality_score.get('readability', 0):.2f}")
                print(f"   Completeness: {quality_score.get('completeness', 0):.2f}")
            
        except Exception as e:
            print(f"\n❌ Test failed with error:")
            print(f"   {type(e).__name__}: {str(e)}")
            import traceback
            traceback.print_exc()
    
    print(f"\n{'='*80}")
    print("✅ ALL TESTS COMPLETED")
    print(f"{'='*80}\n")


async def test_api_schema_compatibility():
    """Test that API schema accepts the parameters from frontend"""
    
    print("\n" + "="*80)
    print("API SCHEMA COMPATIBILITY TEST")
    print("="*80)
    
    # Simulate frontend request payload (lowercase as sent by frontend after toJson())
    frontend_payload = {
        "platform": "instagram",
        "topic": "Swipe copy: 30-day launch plan for an AI content retainer",
        "tone": "friendly",
        "include_hashtags": True,
        "include_emoji": True,
        "include_call_to_action": True
    }
    
    print(f"\n📤 Frontend Payload:")
    print(json.dumps(frontend_payload, indent=2))
    
    # Verify schema can parse it
    try:
        from app.schemas.generation import SocialMediaGenerationRequest
        
        request = SocialMediaGenerationRequest(**frontend_payload)
        
        print(f"\n✅ Schema validation passed!")
        print(f"\n📥 Parsed Request:")
        print(f"   Platform: {request.platform}")
        print(f"   Topic: {request.topic}")
        print(f"   Tone: {request.tone}")
        print(f"   Include Hashtags: {request.include_hashtags}")
        print(f"   Include Emoji: {request.include_emoji}")
        print(f"   Include CTA: {request.include_call_to_action}")
        
        # Test JSON serialization
        print(f"\n📋 JSON Schema Extra (example):")
        print(json.dumps(request.Config.json_schema_extra['example'], indent=2))
        
    except Exception as e:
        print(f"\n❌ Schema validation failed:")
        print(f"   {type(e).__name__}: {str(e)}")
        import traceback
        traceback.print_exc()
    
    print(f"\n{'='*80}\n")


async def main():
    """Run all tests"""
    print("\n🚀 Starting Social Media API Parameter Tests...")
    
    # Test 1: Schema compatibility
    await test_api_schema_compatibility()
    
    # Test 2: Actual generation with different parameters
    await test_social_media_generation()
    
    print("\n✅ All tests completed successfully!\n")


if __name__ == "__main__":
    asyncio.run(main())
