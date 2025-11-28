#!/usr/bin/env python3
"""
Batch Image Generation Test Script
Tests both single and batch image generation endpoints
"""
import requests
import json
import time
from typing import List, Dict, Any

# Configuration
BASE_URL = "http://localhost:8000"
AUTH_TOKEN = ""  # Get from app after login

class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    END = '\033[0m'

def print_header(text: str):
    print(f"\n{Colors.HEADER}{Colors.BOLD}{'='*60}{Colors.END}")
    print(f"{Colors.HEADER}{Colors.BOLD}{text}{Colors.END}")
    print(f"{Colors.HEADER}{Colors.BOLD}{'='*60}{Colors.END}\n")

def print_success(text: str):
    print(f"{Colors.GREEN}✅ {text}{Colors.END}")

def print_error(text: str):
    print(f"{Colors.FAIL}❌ {text}{Colors.END}")

def print_info(text: str):
    print(f"{Colors.CYAN}ℹ️  {text}{Colors.END}")

def print_warning(text: str):
    print(f"{Colors.WARNING}⚠️  {text}{Colors.END}")

def test_single_image():
    """Test single image generation"""
    print_header("TEST 1: Single Image Generation")
    
    endpoint = f"{BASE_URL}/api/v1/generate/image"
    headers = {
        "Authorization": f"Bearer {AUTH_TOKEN}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "prompt": "Modern minimalist office workspace with natural lighting and plants",
        "style": "realistic",
        "aspect_ratio": "16:9",
        "size": "1792x1024",
        "enhance_prompt": True
    }
    
    print_info(f"Prompt: {payload['prompt']}")
    print_info(f"Style: {payload['style']}")
    print_info(f"Aspect Ratio: {payload['aspect_ratio']}")
    
    try:
        start = time.time()
        response = requests.post(endpoint, headers=headers, json=payload, timeout=30)
        duration = time.time() - start
        
        if response.status_code == 201:
            data = response.json()
            print_success(f"Generated in {duration:.2f}s")
            print_info(f"Image URL: {data['image_url'][:80]}...")
            print_info(f"Model: {data['model']}")
            print_info(f"Generation Time: {data['generation_time']:.2f}s")
            print_info(f"Cost: ${data['cost']:.4f}")
            print_info(f"Size: {data['size']}")
            print_info(f"Quality: {data['quality']}")
            print_info(f"Enhanced Prompt: {data['prompt_used'][:100]}...")
            return True
        else:
            print_error(f"Failed with status {response.status_code}")
            print_error(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print_error(f"Exception: {e}")
        return False

def test_batch_generation_small():
    """Test small batch (3 images)"""
    print_header("TEST 2: Small Batch Generation (3 images)")
    
    endpoint = f"{BASE_URL}/api/v1/generate/image/batch"
    headers = {
        "Authorization": f"Bearer {AUTH_TOKEN}",
        "Content-Type": "application/json"
    }
    
    prompts = [
        "Cozy coffee shop interior with vintage decor and warm lighting",
        "Modern tech startup office with glass walls",
        "Minimalist bedroom with natural light and plants"
    ]
    
    payload = {
        "prompts": prompts,
        "style": "realistic",
        "size": "1024x1024",
        "enhance_prompts": True
    }
    
    print_info(f"Generating {len(prompts)} images:")
    for i, p in enumerate(prompts, 1):
        print(f"  {i}. {p}")
    
    try:
        start = time.time()
        response = requests.post(endpoint, headers=headers, json=payload, timeout=60)
        duration = time.time() - start
        
        if response.status_code == 201:
            data = response.json()
            print_success(f"Batch completed in {duration:.2f}s")
            print_info(f"Total Images: {data['count']}")
            print_info(f"Total Cost: ${data['total_cost']:.4f}")
            print_info(f"Total Time: {data['total_time']:.2f}s")
            print_info(f"Average Time/Image: {data['total_time']/data['count']:.2f}s")
            
            print(f"\n{Colors.CYAN}📊 Individual Results:{Colors.END}")
            for i, img in enumerate(data['images'], 1):
                print(f"\n  Image {i}:")
                print(f"    URL: {img['image_url'][:70]}...")
                print(f"    Time: {img['generation_time']:.2f}s")
                print(f"    Cost: ${img['cost']:.4f}")
                print(f"    Model: {img['model']}")
            
            return True
        else:
            print_error(f"Failed with status {response.status_code}")
            print_error(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print_error(f"Exception: {e}")
        return False

def test_batch_generation_large():
    """Test large batch (10 images)"""
    print_header("TEST 3: Large Batch Generation (10 images)")
    
    endpoint = f"{BASE_URL}/api/v1/generate/image/batch"
    headers = {
        "Authorization": f"Bearer {AUTH_TOKEN}",
        "Content-Type": "application/json"
    }
    
    prompts = [
        "Professional product photo of a smartwatch",
        "Elegant restaurant interior with chandelier",
        "Modern gym with exercise equipment",
        "Luxurious spa treatment room",
        "Creative art studio workspace",
        "High-tech conference room",
        "Stylish boutique clothing store",
        "Serene yoga studio with bamboo floors",
        "Industrial loft apartment living room",
        "Outdoor patio with string lights and plants"
    ]
    
    payload = {
        "prompts": prompts,
        "style": "realistic",
        "size": "1024x1024",
        "enhance_prompts": True
    }
    
    print_info(f"Generating {len(prompts)} images")
    print_warning("This may take 5-10 seconds...")
    
    try:
        start = time.time()
        response = requests.post(endpoint, headers=headers, json=payload, timeout=90)
        duration = time.time() - start
        
        if response.status_code == 201:
            data = response.json()
            print_success(f"Batch completed in {duration:.2f}s")
            print_info(f"Total Images: {data['count']}")
            print_info(f"Total Cost: ${data['total_cost']:.4f}")
            print_info(f"Total Time: {data['total_time']:.2f}s")
            print_info(f"Average Time/Image: {data['total_time']/data['count']:.2f}s")
            print_info(f"Throughput: {data['count']/duration:.2f} images/sec")
            
            # Check all succeeded
            success_count = len(data['images'])
            if success_count == len(prompts):
                print_success(f"All {success_count} images generated successfully!")
            else:
                print_warning(f"Only {success_count}/{len(prompts)} images generated")
            
            return True
        else:
            print_error(f"Failed with status {response.status_code}")
            print_error(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print_error(f"Exception: {e}")
        return False

def test_different_styles():
    """Test all available styles"""
    print_header("TEST 4: Different Styles")
    
    endpoint = f"{BASE_URL}/api/v1/generate/image/batch"
    headers = {
        "Authorization": f"Bearer {AUTH_TOKEN}",
        "Content-Type": "application/json"
    }
    
    styles = ["realistic", "artistic", "illustration", "3d"]
    prompt = "Beautiful mountain landscape at sunset"
    
    all_prompts = [prompt] * len(styles)
    
    payload = {
        "prompts": all_prompts,
        "style": "realistic",  # Will test each style separately
        "size": "1024x1024",
        "enhance_prompts": True
    }
    
    results = {}
    
    for style in styles:
        print_info(f"Testing style: {style}")
        payload["style"] = style
        
        try:
            response = requests.post(endpoint, headers=headers, json=payload, timeout=60)
            
            if response.status_code == 201:
                data = response.json()
                results[style] = {
                    "success": True,
                    "time": data['total_time'],
                    "cost": data['total_cost']
                }
                print_success(f"{style}: {data['total_time']:.2f}s, ${data['total_cost']:.4f}")
            else:
                results[style] = {"success": False}
                print_error(f"{style}: Failed")
                
        except Exception as e:
            results[style] = {"success": False}
            print_error(f"{style}: {e}")
    
    # Summary
    print(f"\n{Colors.CYAN}📊 Style Comparison:{Colors.END}")
    successful = [s for s, r in results.items() if r.get("success")]
    print_info(f"Successful: {len(successful)}/{len(styles)}")
    
    if successful:
        avg_time = sum(results[s]["time"] for s in successful) / len(successful)
        avg_cost = sum(results[s]["cost"] for s in successful) / len(successful)
        print_info(f"Average Time: {avg_time:.2f}s")
        print_info(f"Average Cost: ${avg_cost:.4f}")
    
    return len(successful) == len(styles)

def test_different_aspect_ratios():
    """Test all aspect ratios"""
    print_header("TEST 5: Different Aspect Ratios")
    
    endpoint = f"{BASE_URL}/api/v1/generate/image/batch"
    headers = {
        "Authorization": f"Bearer {AUTH_TOKEN}",
        "Content-Type": "application/json"
    }
    
    ratios = {
        "1:1": "1024x1024",
        "16:9": "1792x1024",
        "9:16": "1024x1792",
        "4:3": "1365x1024",
        "3:4": "1024x1365"
    }
    
    prompt = "Modern office workspace"
    all_prompts = [prompt] * len(ratios)
    
    payload = {
        "prompts": all_prompts,
        "style": "realistic",
        "size": "1024x1024",  # Will be overridden
        "enhance_prompts": True
    }
    
    print_info(f"Testing {len(ratios)} aspect ratios")
    
    results = []
    for ratio, size in ratios.items():
        payload["size"] = size
        
        try:
            response = requests.post(
                endpoint.replace("/batch", ""),  # Use single endpoint
                headers=headers,
                json={**payload, "prompts": None, "prompt": prompt, "aspect_ratio": ratio},
                timeout=30
            )
            
            if response.status_code == 201:
                data = response.json()
                results.append(ratio)
                print_success(f"{ratio} ({size}): {data['generation_time']:.2f}s")
            else:
                print_error(f"{ratio}: Failed")
                
        except Exception as e:
            print_error(f"{ratio}: {e}")
    
    print_info(f"Successful: {len(results)}/{len(ratios)}")
    return len(results) == len(ratios)

def run_all_tests():
    """Run all tests"""
    print_header("🚀 BATCH IMAGE GENERATION TEST SUITE")
    
    if not AUTH_TOKEN:
        print_error("AUTH_TOKEN not set!")
        print_info("Please login to the app and copy your token")
        print_info("Then update AUTH_TOKEN variable in this script")
        return
    
    print_info(f"Base URL: {BASE_URL}")
    print_info(f"Using auth token: {AUTH_TOKEN[:20]}...")
    
    tests = [
        ("Single Image", test_single_image),
        ("Small Batch (3)", test_batch_generation_small),
        ("Large Batch (10)", test_batch_generation_large),
        ("Different Styles", test_different_styles),
        ("Different Ratios", test_different_aspect_ratios),
    ]
    
    results = []
    
    for name, test_func in tests:
        try:
            result = test_func()
            results.append((name, result))
        except Exception as e:
            print_error(f"Test '{name}' crashed: {e}")
            results.append((name, False))
    
    # Final summary
    print_header("📊 TEST SUMMARY")
    
    passed = sum(1 for _, r in results if r)
    total = len(results)
    
    for name, result in results:
        if result:
            print_success(f"{name}: PASSED")
        else:
            print_error(f"{name}: FAILED")
    
    print(f"\n{Colors.BOLD}Final Score: {passed}/{total} tests passed{Colors.END}")
    
    if passed == total:
        print_success("🎉 All tests passed!")
    else:
        print_warning(f"⚠️  {total - passed} test(s) failed")

if __name__ == "__main__":
    print(f"{Colors.CYAN}Before running tests:{Colors.END}")
    print("1. Make sure backend is running: uvicorn app.main:app --reload")
    print("2. Login to the app and get your auth token")
    print("3. Update AUTH_TOKEN variable in this script")
    print("4. Run: python test_batch_images.py\n")
    
    if AUTH_TOKEN:
        run_all_tests()
    else:
        print_error("Please set AUTH_TOKEN first!")
