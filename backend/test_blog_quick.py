"""
Quick Blog Generation Test - Single 500-word blog
"""
import asyncio
import sys
import os

# Add backend to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.services.openai_service import OpenAIService


async def test_single_blog():
    """Test a single blog generation"""
    print("="*80)
    print("🧪 TESTING: 500 Word Blog Generation with New SDK")
    print("="*80)
    
    service = OpenAIService()
    
    try:
        print("\n⏳ Generating 500-word blog about AI in healthcare...\n")
        
        result = await service.generate_blog_post(
            topic="How Artificial Intelligence is Transforming Healthcare",
            keywords=["artificial intelligence", "healthcare", "medical AI"],
            tone="professional",
            word_count=500,
            sections=None,
            user_tier="free",
            user_id="test_user",
            target_audience="healthcare professionals",
            writing_style=None,
            include_examples=True,
            enable_fact_check=False
        )
        
        # Extract data
        output = result['output']
        tokens = result['tokensUsed']
        model = result['model']
        validation = result['validation']
        gen_time = result['generation_time']
        
        # Display results
        print("✅ SUCCESS!\n")
        print(f"⏱️  Generation Time: {gen_time:.2f}s")
        print(f"🎯 Model: {model}")
        print(f"📊 Tokens Used: {tokens}")
        print(f"📝 Word Count: {output.get('wordCount', 0)} (target: 450-550)")
        print(f"✨ Accuracy: {validation['word_count_accuracy']}%")
        print(f"⭐ Quality Score: {validation['quality_score']}")
        print(f"✓  Valid: {validation['valid']}\n")
        
        # Display content
        print(f"📰 TITLE: {output.get('title', 'N/A')}\n")
        print(f"📝 META: {output.get('metaDescription', 'N/A')}\n")
        print(f"🗂️  SECTIONS ({len(output.get('sections', []))}):")
        for i, section in enumerate(output.get('sections', []), 1):
            print(f"   {i}. {section.get('heading', 'N/A')}")
        
        print(f"\n📖 INTRODUCTION:")
        intro = output.get('introduction', '')
        print(f"{intro[:300]}...\n")
        
        if validation['valid'] and validation['word_count_accuracy'] >= 90:
            print("🎉 TEST PASSED! Migration successful!\n")
            return True
        else:
            print("⚠️  TEST WARNING: Validation issues detected\n")
            return False
            
    except Exception as e:
        print(f"\n❌ TEST FAILED: {str(e)}\n")
        import traceback
        traceback.print_exc()
        return False


if __name__ == "__main__":
    success = asyncio.run(test_single_blog())
    sys.exit(0 if success else 1)
