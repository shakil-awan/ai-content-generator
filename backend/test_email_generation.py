"""
Test Email Campaign Generation with New SDK Migration
Tests various campaign types and tones to verify Milestone 5 completion
"""
import asyncio
import sys
import os
from datetime import datetime

# Add backend to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.services.openai_service import OpenAIService


async def test_email_generation(
    campaign_type: str,
    product_service: str,
    target_audience: str,
    goal: str,
    tone: str,
    test_name: str
):
    """Test email campaign generation with specific parameters"""
    print(f"\n{'='*80}")
    print(f"🧪 TEST: {test_name}")
    print(f"{'='*80}")
    print(f"📧 Campaign Type: {campaign_type}")
    print(f"🎯 Tone: {tone}")
    print(f"🛍️  Product/Service: {product_service}")
    print(f"👥 Target Audience: {target_audience}")
    print(f"🎯 Goal: {goal}")
    print(f"\n⏳ Generating...")
    
    service = OpenAIService()
    
    start_time = datetime.now()
    
    try:
        result = await service.generate_email_campaign(
            campaign_type=campaign_type,
            product_service=product_service,
            target_audience=target_audience,
            goal=goal,
            tone=tone,
            user_tier="free",
            user_id="test_user"
        )
        
        elapsed = (datetime.now() - start_time).total_seconds()
        
        # Extract output
        output = result['output']
        tokens = result['tokensUsed']
        model = result['model']
        gen_time = result.get('generation_time', 0)
        
        # Display results
        print(f"\n✅ SUCCESS!")
        print(f"⏱️  Generation Time: {elapsed:.2f}s (reported: {gen_time:.2f}s)")
        print(f"🎯 Model: {model}")
        print(f"📊 Tokens Used: {tokens}")
        
        # Display email structure
        print(f"\n📧 SUBJECT: {output.get('subject', 'N/A')}")
        print(f"📝 PREHEADER: {output.get('preheader', 'N/A')}")
        
        body = output.get('body', '')
        print(f"\n📖 BODY ({len(body)} chars):")
        print(f"{body[:300]}..." if len(body) > 300 else body)
        
        print(f"\n🔘 CTA: {output.get('callToAction', 'N/A')}")
        
        # Validation checks
        subject_len = len(output.get('subject', ''))
        preheader_len = len(output.get('preheader', ''))
        has_body = len(body) > 50
        has_cta = len(output.get('callToAction', '')) > 0
        
        all_valid = (40 <= subject_len <= 70 and 
                    40 <= preheader_len <= 110 and 
                    has_body and has_cta)
        
        print(f"\n✓ Validation:")
        print(f"  - Subject: {subject_len} chars {'✅' if 40 <= subject_len <= 70 else '⚠️'} (target: 40-60)")
        print(f"  - Preheader: {preheader_len} chars {'✅' if 40 <= preheader_len <= 110 else '⚠️'} (target: 40-100)")
        print(f"  - Body: {'✅' if has_body else '❌'} (substantial content)")
        print(f"  - CTA: {'✅' if has_cta else '❌'} (present)")
        
        return {
            'success': True,
            'valid': all_valid,
            'tokens': tokens,
            'time': elapsed
        }
        
    except Exception as e:
        print(f"\n❌ FAILED: {str(e)}")
        import traceback
        traceback.print_exc()
        return {
            'success': False,
            'error': str(e)
        }


async def run_all_tests():
    """Run comprehensive test suite for email generation"""
    print(f"""
{'='*80}
🚀 EMAIL CAMPAIGN GENERATION TEST SUITE - MILESTONE 5
{'='*80}
Testing new Gemini SDK with Pydantic EmailCampaignOutput schema
Testing various campaign types and tones
{'='*80}
""")
    
    # Test cases
    tests = [
        {
            'name': 'Promotional Email - Professional Tone',
            'campaign_type': 'promotional',
            'product_service': 'Premium AI Writing Assistant',
            'target_audience': 'Content creators and marketers',
            'goal': 'Drive subscriptions with 30% discount offer',
            'tone': 'professional'
        },
        {
            'name': 'Newsletter - Friendly Tone',
            'campaign_type': 'newsletter',
            'product_service': 'Tech Industry News & Insights',
            'target_audience': 'Tech professionals and enthusiasts',
            'goal': 'Increase engagement and readership',
            'tone': 'friendly'
        },
        {
            'name': 'Welcome Email - Casual Tone',
            'campaign_type': 'welcome',
            'product_service': 'Fitness App with Personalized Workouts',
            'target_audience': 'New users who just signed up',
            'goal': 'Complete onboarding and first workout',
            'tone': 'casual'
        },
        {
            'name': 'Product Launch - Inspirational Tone',
            'campaign_type': 'product_launch',
            'product_service': 'Revolutionary Smart Home Device',
            'target_audience': 'Early adopters and tech enthusiasts',
            'goal': 'Pre-orders and waitlist signups',
            'tone': 'inspirational'
        }
    ]
    
    results = []
    
    for test in tests:
        result = await test_email_generation(
            campaign_type=test['campaign_type'],
            product_service=test['product_service'],
            target_audience=test['target_audience'],
            goal=test['goal'],
            tone=test['tone'],
            test_name=test['name']
        )
        results.append({**test, **result})
        
        # Brief pause between tests
        await asyncio.sleep(2)
    
    # Summary
    print(f"\n{'='*80}")
    print(f"📊 TEST SUMMARY")
    print(f"{'='*80}")
    
    total_tests = len(results)
    successful_tests = sum(1 for r in results if r.get('success'))
    valid_tests = sum(1 for r in results if r.get('success') and r.get('valid'))
    failed_tests = total_tests - successful_tests
    
    print(f"✅ Successful: {successful_tests}/{total_tests}")
    print(f"✓  Valid: {valid_tests}/{total_tests}")
    print(f"❌ Failed: {failed_tests}/{total_tests}")
    
    if successful_tests > 0:
        avg_tokens = sum(r.get('tokens', 0) for r in results if r.get('success')) / successful_tests
        avg_time = sum(r.get('time', 0) for r in results if r.get('success')) / successful_tests
        
        print(f"\n📈 AVERAGES:")
        print(f"   Tokens Used: {avg_tokens:.0f}")
        print(f"   Generation Time: {avg_time:.2f}s")
    
    print(f"\n{'='*80}")
    
    # Detailed results table
    print(f"\n📋 DETAILED RESULTS:")
    print(f"{'-'*80}")
    print(f"{'Test':<40} {'Tokens':<10} {'Time':<10} {'Status'}")
    print(f"{'-'*80}")
    
    for r in results:
        status = "✅ PASS" if r.get('success') and r.get('valid') else ("⚠️ WARN" if r.get('success') else "❌ FAIL")
        tokens = str(r.get('tokens', 0)) if r.get('success') else "N/A"
        time_str = f"{r.get('time', 0):.2f}s" if r.get('success') else "N/A"
        
        print(f"{r['name']:<40} {tokens:<10} {time_str:<10} {status}")
    
    print(f"{'-'*80}")
    
    # Final verdict
    if successful_tests == total_tests and valid_tests == total_tests:
        print(f"\n🎉 ALL TESTS PASSED! Milestone 5 ready for completion.")
    elif successful_tests > 0:
        print(f"\n⚠️  PARTIAL SUCCESS: {successful_tests}/{total_tests} tests passed, {valid_tests}/{total_tests} valid.")
    else:
        print(f"\n❌ ALL TESTS FAILED! Migration needs review.")
    
    print(f"\n{'='*80}\n")


if __name__ == "__main__":
    asyncio.run(run_all_tests())
