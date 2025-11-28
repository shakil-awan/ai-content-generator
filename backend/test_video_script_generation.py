"""
Test Video Script Generation with New SDK Migration
Tests various platforms and durations to verify Milestone 6 completion
"""
import asyncio
import sys
import os
from datetime import datetime

# Add backend to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.services.openai_service import OpenAIService


async def test_video_script_generation(
    topic: str,
    duration_seconds: int,
    platform: str,
    target_audience: str,
    key_points: list,
    cta: str,
    test_name: str
):
    """Test video script generation with specific parameters"""
    print(f"\n{'='*80}")
    print(f"🧪 TEST: {test_name}")
    print(f"{'='*80}")
    print(f"🎥 Platform: {platform}")
    print(f"⏱️  Duration: {duration_seconds}s ({duration_seconds // 60}:{duration_seconds % 60:02d})")
    print(f"📝 Topic: {topic}")
    print(f"👥 Target Audience: {target_audience}")
    print(f"🎯 Key Points: {', '.join(key_points)}")
    print(f"📣 CTA: {cta}")
    print(f"\n⏳ Generating...")
    
    service = OpenAIService()
    
    start_time = datetime.now()
    
    try:
        result = await service.generate_video_script(
            topic=topic,
            duration_seconds=duration_seconds,
            platform=platform,
            target_audience=target_audience,
            key_points=key_points,
            cta=cta,
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
        
        # Display script structure
        print(f"\n🎬 TITLE: {output.get('title', 'N/A')}")
        print(f"📝 DESCRIPTION: {output.get('description', 'N/A')[:100]}...")
        print(f"⏱️  TOTAL DURATION: {output.get('totalDuration', 'N/A')}")
        
        sections = output.get('sections', [])
        print(f"\n📋 SECTIONS ({len(sections)}):")
        for i, section in enumerate(sections[:5], 1):  # Show first 5
            section_type = section.get('sectionType', 'N/A')
            timestamp = section.get('timestamp', 'N/A')
            script_preview = section.get('script', '')[:80]
            print(f"   {i}. [{timestamp}] {section_type}: {script_preview}...")
        
        if len(sections) > 5:
            print(f"   ... and {len(sections) - 5} more sections")
        
        # Validation checks
        has_title = len(output.get('title', '')) > 0
        has_description = len(output.get('description', '')) > 50
        has_sections = len(sections) >= 3
        has_duration = output.get('totalDuration', '') != ''
        
        all_valid = has_title and has_description and has_sections and has_duration
        
        print(f"\n✓ Validation:")
        print(f"  - Title: {'✅' if has_title else '❌'}")
        print(f"  - Description: {'✅' if has_description else '❌'} (substantial content)")
        print(f"  - Sections: {'✅' if has_sections else '❌'} ({len(sections)} sections)")
        print(f"  - Duration: {'✅' if has_duration else '❌'}")
        
        return {
            'success': True,
            'valid': all_valid,
            'tokens': tokens,
            'time': elapsed,
            'sections': len(sections)
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
    """Run comprehensive test suite for video script generation"""
    print(f"""
{'='*80}
🚀 VIDEO SCRIPT GENERATION TEST SUITE - MILESTONE 6
{'='*80}
Testing new Gemini SDK with Pydantic VideoScriptOutput schema
Testing various platforms and durations
Using Gemini 2.5 Flash models
{'='*80}
""")
    
    # Test cases
    tests = [
        {
            'name': '30s TikTok - Tech Tips',
            'topic': '5 Essential AI Tools Every Content Creator Needs',
            'duration_seconds': 30,
            'platform': 'tiktok',
            'target_audience': 'Content creators and social media managers',
            'key_points': ['ChatGPT for writing', 'Midjourney for images', 'Descript for editing'],
            'cta': 'Follow for more AI tips!'
        },
        {
            'name': '60s Instagram - Fitness',
            'topic': 'Quick Morning Workout Routine for Busy Professionals',
            'duration_seconds': 60,
            'platform': 'instagram',
            'target_audience': 'Busy professionals aged 25-40',
            'key_points': ['5-minute routine', 'No equipment needed', 'Energy boost'],
            'cta': 'Save this and try it tomorrow!'
        },
        {
            'name': '120s YouTube - Tutorial',
            'topic': 'How to Create Stunning AI Art in Minutes',
            'duration_seconds': 120,
            'platform': 'youtube',
            'target_audience': 'Digital artists and designers',
            'key_points': ['Choose the right tool', 'Craft effective prompts', 'Refine your results'],
            'cta': 'Subscribe for more AI tutorials!'
        },
        {
            'name': '45s Facebook - Product Demo',
            'topic': 'Revolutionary Smart Home Device That Saves Energy',
            'duration_seconds': 45,
            'platform': 'facebook',
            'target_audience': 'Homeowners interested in smart technology',
            'key_points': ['Automatic energy optimization', 'Easy setup', '30% savings'],
            'cta': 'Learn more at the link!'
        }
    ]
    
    results = []
    
    for test in tests:
        result = await test_video_script_generation(
            topic=test['topic'],
            duration_seconds=test['duration_seconds'],
            platform=test['platform'],
            target_audience=test['target_audience'],
            key_points=test['key_points'],
            cta=test['cta'],
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
        avg_sections = sum(r.get('sections', 0) for r in results if r.get('success')) / successful_tests
        
        print(f"\n📈 AVERAGES:")
        print(f"   Tokens Used: {avg_tokens:.0f}")
        print(f"   Generation Time: {avg_time:.2f}s")
        print(f"   Sections per Script: {avg_sections:.1f}")
    
    print(f"\n{'='*80}")
    
    # Detailed results table
    print(f"\n📋 DETAILED RESULTS:")
    print(f"{'-'*80}")
    print(f"{'Test':<35} {'Sections':<10} {'Tokens':<10} {'Time':<10} {'Status'}")
    print(f"{'-'*80}")
    
    for r in results:
        status = "✅ PASS" if r.get('success') and r.get('valid') else ("⚠️ WARN" if r.get('success') else "❌ FAIL")
        sections = str(r.get('sections', 0)) if r.get('success') else "N/A"
        tokens = str(r.get('tokens', 0)) if r.get('success') else "N/A"
        time_str = f"{r.get('time', 0):.2f}s" if r.get('success') else "N/A"
        
        print(f"{r['name']:<35} {sections:<10} {tokens:<10} {time_str:<10} {status}")
    
    print(f"{'-'*80}")
    
    # Final verdict
    if successful_tests == total_tests and valid_tests == total_tests:
        print(f"\n🎉 ALL TESTS PASSED! Milestone 6 ready for completion.")
    elif successful_tests > 0:
        print(f"\n⚠️  PARTIAL SUCCESS: {successful_tests}/{total_tests} tests passed, {valid_tests}/{total_tests} valid.")
    else:
        print(f"\n❌ ALL TESTS FAILED! Migration needs review.")
    
    print(f"\n{'='*80}\n")


if __name__ == "__main__":
    asyncio.run(run_all_tests())
