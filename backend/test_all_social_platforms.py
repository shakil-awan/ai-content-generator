#!/usr/bin/env python3
"""
Comprehensive Social Media Generation Test Script
Tests all platforms (LinkedIn, Twitter, Instagram, TikTok) with various tones
"""

import asyncio
import sys
import json
from datetime import datetime

sys.path.insert(0, '/Users/muhammadshakil/Projects/ai_content_generator/backend')

from app.services.openai_service import OpenAIService

# Test configurations for each platform - using simple, safe content
TEST_CONFIGS = [
    {
        'platform': 'linkedin',
        'content': 'Sharing insights from our recent team workshop on effective collaboration',
        'audience': 'Business professionals',
        'tone': 'professional',
    },
    {
        'platform': 'twitter',
        'content': 'Morning coffee and planning the day ahead',
        'audience': 'Coffee enthusiasts',
        'tone': 'casual',
    },
    {
        'platform': 'instagram',
        'content': 'Beautiful sunset views from our office rooftop',
        'audience': 'Photography lovers',
        'tone': 'inspirational',
    },
    {
        'platform': 'tiktok',
        'content': 'Quick recipe for the perfect smoothie bowl',
        'audience': 'Health-conscious foodies',
        'tone': 'casual',
    },
]

# ANSI color codes for terminal output
class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def print_header(text):
    """Print colored header"""
    print(f"\n{Colors.HEADER}{Colors.BOLD}{'='*80}")
    print(f"{text.center(80)}")
    print(f"{'='*80}{Colors.ENDC}\n")


def print_section(text):
    """Print colored section"""
    print(f"\n{Colors.OKCYAN}{Colors.BOLD}{text}{Colors.ENDC}")
    print(f"{Colors.OKCYAN}{'-'*len(text)}{Colors.ENDC}")


def print_success(text):
    """Print success message"""
    print(f"{Colors.OKGREEN}✓ {text}{Colors.ENDC}")


def print_error(text):
    """Print error message"""
    print(f"{Colors.FAIL}✗ {text}{Colors.ENDC}")


def print_info(label, value):
    """Print info line"""
    print(f"{Colors.OKBLUE}{label}:{Colors.ENDC} {value}")


def validate_response_structure(output, platform):
    """Validate that response matches expected schema"""
    errors = []
    
    # Check required fields
    if 'captions' not in output:
        errors.append("Missing 'captions' field")
    elif not isinstance(output['captions'], list):
        errors.append("'captions' is not an array")
    elif len(output['captions']) != 5:
        errors.append(f"Expected 5 captions, got {len(output['captions'])}")
    else:
        # Validate each caption
        for i, caption in enumerate(output['captions'], 1):
            if not isinstance(caption, dict):
                errors.append(f"Caption {i} is not an object")
                continue
            if 'variation' not in caption:
                errors.append(f"Caption {i} missing 'variation' field")
            if 'text' not in caption:
                errors.append(f"Caption {i} missing 'text' field")
            if 'length' not in caption:
                errors.append(f"Caption {i} missing 'length' field")
    
    if 'hashtags' not in output:
        errors.append("Missing 'hashtags' field")
    elif not isinstance(output['hashtags'], list):
        errors.append("'hashtags' is not an array")
    
    if 'emojiSuggestions' not in output:
        errors.append("Missing 'emojiSuggestions' field")
    elif not isinstance(output['emojiSuggestions'], list):
        errors.append("'emojiSuggestions' is not an array")
    
    if 'engagementTips' not in output:
        errors.append("Missing 'engagementTips' field")
    elif not isinstance(output['engagementTips'], str):
        errors.append("'engagementTips' is not a string")
    
    return errors


async def test_platform(service, config):
    """Test a single platform configuration"""
    platform = config['platform']
    
    print_section(f"Testing {platform.upper()}")
    print_info("Content", config['content'][:60] + '...')
    print_info("Audience", config['audience'])
    print_info("Tone", config['tone'])
    
    try:
        start_time = datetime.now()
        
        result = await service.generate_social_media(
            content_description=config['content'],
            platform=platform,
            target_audience=config['audience'],
            tone=config['tone'],
            include_cta=True,
            include_hashtags=True,
            include_emoji=True
        )
        
        end_time = datetime.now()
        duration = (end_time - start_time).total_seconds()
        
        output = result['output']
        
        # Validate structure
        validation_errors = validate_response_structure(output, platform)
        
        if validation_errors:
            print_error("Validation Failed:")
            for error in validation_errors:
                print(f"  • {error}")
            return False
        
        print_success("Validation Passed")
        
        # Display metrics
        print_info("Model", result['model'])
        print_info("Tokens Used", result['tokensUsed'])
        print_info("Generation Time", f"{duration:.2f}s")
        print_info("Captions Generated", len(output['captions']))
        print_info("Hashtags Generated", len(output['hashtags']))
        print_info("Emojis Suggested", len(output['emojiSuggestions']))
        
        # Display first caption
        print(f"\n{Colors.BOLD}Sample Caption (Variation 1):{Colors.ENDC}")
        first_caption = output['captions'][0]
        caption_text = first_caption['text']
        if len(caption_text) > 200:
            caption_text = caption_text[:200] + "..."
        print(f"  {caption_text}")
        print_info("  Character Count", first_caption['length'])
        
        # Display hashtags
        if output['hashtags']:
            print(f"\n{Colors.BOLD}Hashtags:{Colors.ENDC}")
            hashtag_display = ' '.join(output['hashtags'][:5])
            if len(output['hashtags']) > 5:
                hashtag_display += f" + {len(output['hashtags']) - 5} more"
            print(f"  {hashtag_display}")
        
        # Display emojis
        if output['emojiSuggestions']:
            print(f"\n{Colors.BOLD}Emoji Suggestions:{Colors.ENDC}")
            emoji_display = ' '.join(output['emojiSuggestions'][:8])
            print(f"  {emoji_display}")
        
        # Display engagement tips
        print(f"\n{Colors.BOLD}Engagement Tips:{Colors.ENDC}")
        tips = output['engagementTips']
        if len(tips) > 150:
            tips = tips[:150] + "..."
        print(f"  {tips}")
        
        print_success(f"\n{platform.upper()} Test Passed!")
        return True
        
    except Exception as e:
        print_error(f"Test Failed: {str(e)}")
        import traceback
        print(f"\n{Colors.WARNING}{traceback.format_exc()}{Colors.ENDC}")
        return False


async def main():
    """Run all platform tests"""
    print_header("SOCIAL MEDIA GENERATION - COMPREHENSIVE PLATFORM TEST")
    print(f"{Colors.BOLD}Test Start:{Colors.ENDC} {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{Colors.BOLD}Testing Platforms:{Colors.ENDC} LinkedIn, Twitter, Instagram, TikTok")
    print(f"{Colors.BOLD}Include Options:{Colors.ENDC} CTA=True, Hashtags=True, Emoji=True")
    
    service = OpenAIService()
    
    results = []
    total_start = datetime.now()
    
    for config in TEST_CONFIGS:
        success = await test_platform(service, config)
        results.append({
            'platform': config['platform'],
            'success': success
        })
        
        # Small delay between tests
        if config != TEST_CONFIGS[-1]:
            await asyncio.sleep(2)
    
    total_end = datetime.now()
    total_duration = (total_end - total_start).total_seconds()
    
    # Print summary
    print_header("TEST SUMMARY")
    
    passed = sum(1 for r in results if r['success'])
    failed = len(results) - passed
    
    for result in results:
        platform = result['platform'].upper()
        if result['success']:
            print_success(f"{platform}: PASSED")
        else:
            print_error(f"{platform}: FAILED")
    
    print(f"\n{Colors.BOLD}Results:{Colors.ENDC}")
    print_info("  Total Tests", len(results))
    print_info("  Passed", f"{Colors.OKGREEN}{passed}{Colors.ENDC}")
    if failed > 0:
        print_info("  Failed", f"{Colors.FAIL}{failed}{Colors.ENDC}")
    else:
        print_info("  Failed", "0")
    print_info("  Total Time", f"{total_duration:.2f}s")
    
    if failed == 0:
        print(f"\n{Colors.OKGREEN}{Colors.BOLD}🎉 ALL TESTS PASSED! 🎉{Colors.ENDC}")
        return 0
    else:
        print(f"\n{Colors.FAIL}{Colors.BOLD}⚠️  SOME TESTS FAILED{Colors.ENDC}")
        return 1


if __name__ == "__main__":
    exit_code = asyncio.run(main())
    sys.exit(exit_code)
