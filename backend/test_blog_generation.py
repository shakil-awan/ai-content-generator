"""
Test Blog Generation with New SDK Migration
Tests various word counts, tones, and features to verify Milestone 4 completion
"""
import asyncio
import sys
import os
from datetime import datetime

# Add backend to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.services.openai_service import OpenAIService
from app.config import settings


async def test_blog_generation(
    word_count: int,
    tone: str,
    keywords: list,
    topic: str,
    test_name: str
):
    """Test blog generation with specific parameters"""
    print(f"\n{'='*80}")
    print(f"🧪 TEST: {test_name}")
    print(f"{'='*80}")
    print(f"📝 Word Count: {word_count}")
    print(f"🎯 Tone: {tone}")
    print(f"🔑 Keywords: {', '.join(keywords)}")
    print(f"📰 Topic: {topic}")
    print(f"\n⏳ Generating...")
    
    service = OpenAIService()
    
    start_time = datetime.now()
    
    try:
        result = await service.generate_blog_post(
            topic=topic,
            keywords=keywords,
            tone=tone,
            word_count=word_count,
            sections=None,  # Auto-generate sections
            user_tier="free",
            user_id="test_user",
            target_audience="general readers",
            writing_style=None,
            include_examples=True,
            enable_fact_check=False
        )
        
        elapsed = (datetime.now() - start_time).total_seconds()
        
        # Extract output
        output = result['output']
        tokens = result['tokensUsed']
        model = result['model']
        validation = result['validation']
        gen_time = result['generation_time']
        
        # Display results
        print(f"\n✅ SUCCESS!")
        print(f"⏱️  Generation Time: {elapsed:.2f}s (reported: {gen_time:.2f}s)")
        print(f"🎯 Model: {model}")
        print(f"📊 Tokens Used: {tokens}")
        print(f"📝 Actual Word Count: {output.get('wordCount', 0)}")
        print(f"🎯 Target Range: {word_count - 50} - {word_count + 50}")
        print(f"✨ Word Count Accuracy: {validation['word_count_accuracy']}%")
        print(f"⭐ Quality Score: {validation['quality_score']}")
        print(f"✓  Valid: {validation['valid']}")
        
        # Display content structure
        print(f"\n📰 TITLE: {output.get('title', 'N/A')}")
        print(f"📝 META DESCRIPTION ({len(output.get('metaDescription', ''))} chars): {output.get('metaDescription', 'N/A')[:80]}...")
        print(f"🗂️  SECTIONS ({len(output.get('sections', []))}):")
        for i, section in enumerate(output.get('sections', []), 1):
            section_word_count = len(section.get('content', '').split())
            print(f"   {i}. {section.get('heading', 'N/A')} ({section_word_count} words)")
        
        # Keyword check
        content_lower = output.get('introduction', '').lower()
        for section in output.get('sections', []):
            content_lower += section.get('content', '').lower()
        content_lower += output.get('conclusion', '').lower()
        
        primary_keyword = keywords[0].lower()
        keyword_count = content_lower.count(primary_keyword)
        print(f"\n🔑 Primary Keyword '{keywords[0]}' appears: {keyword_count} times")
        
        # Sample content
        intro = output.get('introduction', '')
        if intro:
            print(f"\n📖 INTRODUCTION ({len(intro.split())} words):")
            print(f"{intro[:200]}...")
        
        return {
            'success': True,
            'word_count_accuracy': validation['word_count_accuracy'],
            'quality_score': validation['quality_score'],
            'tokens': tokens,
            'time': elapsed,
            'valid': validation['valid']
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
    """Run comprehensive test suite for blog generation"""
    print(f"""
{'='*80}
🚀 BLOG GENERATION TEST SUITE - MILESTONE 4
{'='*80}
Testing new Gemini SDK with Pydantic BlogPostOutput schema
Testing various word counts, tones, and keywords
{'='*80}
""")
    
    # Test cases
    tests = [
        {
            'name': '500 Word Professional Blog',
            'word_count': 500,
            'tone': 'professional',
            'keywords': ['artificial intelligence', 'machine learning', 'AI technology'],
            'topic': 'How Artificial Intelligence is Transforming Healthcare in 2024'
        },
        {
            'name': '1000 Word Casual Blog',
            'word_count': 1000,
            'tone': 'casual',
            'keywords': ['remote work', 'productivity', 'work from home'],
            'topic': 'Remote Work Tips: How to Stay Productive Working from Home'
        },
        {
            'name': '1500 Word Informative Blog',
            'word_count': 1500,
            'tone': 'informative',
            'keywords': ['sustainable living', 'eco-friendly', 'climate change'],
            'topic': 'Sustainable Living: 15 Eco-Friendly Practices for Everyday Life'
        },
        {
            'name': '2000 Word Formal Blog',
            'word_count': 2000,
            'tone': 'formal',
            'keywords': ['blockchain technology', 'cryptocurrency', 'decentralization'],
            'topic': 'Understanding Blockchain Technology: A Comprehensive Guide for Businesses'
        }
    ]
    
    results = []
    
    for test in tests:
        result = await test_blog_generation(
            word_count=test['word_count'],
            tone=test['tone'],
            keywords=test['keywords'],
            topic=test['topic'],
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
    failed_tests = total_tests - successful_tests
    
    print(f"✅ Successful: {successful_tests}/{total_tests}")
    print(f"❌ Failed: {failed_tests}/{total_tests}")
    
    if successful_tests > 0:
        avg_accuracy = sum(r.get('word_count_accuracy', 0) for r in results if r.get('success')) / successful_tests
        avg_quality = sum(r.get('quality_score', 0) for r in results if r.get('success')) / successful_tests
        avg_tokens = sum(r.get('tokens', 0) for r in results if r.get('success')) / successful_tests
        avg_time = sum(r.get('time', 0) for r in results if r.get('success')) / successful_tests
        
        print(f"\n📈 AVERAGES:")
        print(f"   Word Count Accuracy: {avg_accuracy:.1f}%")
        print(f"   Quality Score: {avg_quality:.2f}")
        print(f"   Tokens Used: {avg_tokens:.0f}")
        print(f"   Generation Time: {avg_time:.2f}s")
    
    print(f"\n{'='*80}")
    
    # Detailed results table
    print(f"\n📋 DETAILED RESULTS:")
    print(f"{'-'*80}")
    print(f"{'Test':<30} {'WC%':<8} {'Quality':<10} {'Tokens':<10} {'Time':<10} {'Status'}")
    print(f"{'-'*80}")
    
    for r in results:
        status = "✅ PASS" if r.get('success') and r.get('valid') else "❌ FAIL"
        wc_accuracy = f"{r.get('word_count_accuracy', 0):.1f}%" if r.get('success') else "N/A"
        quality = f"{r.get('quality_score', 0):.2f}" if r.get('success') else "N/A"
        tokens = str(r.get('tokens', 0)) if r.get('success') else "N/A"
        time_str = f"{r.get('time', 0):.2f}s" if r.get('success') else "N/A"
        
        print(f"{r['name']:<30} {wc_accuracy:<8} {quality:<10} {tokens:<10} {time_str:<10} {status}")
    
    print(f"{'-'*80}")
    
    # Final verdict
    if successful_tests == total_tests:
        print(f"\n🎉 ALL TESTS PASSED! Milestone 4 ready for completion.")
    elif successful_tests > 0:
        print(f"\n⚠️  PARTIAL SUCCESS: {successful_tests}/{total_tests} tests passed.")
    else:
        print(f"\n❌ ALL TESTS FAILED! Migration needs review.")
    
    print(f"\n{'='*80}\n")


if __name__ == "__main__":
    asyncio.run(run_all_tests())
