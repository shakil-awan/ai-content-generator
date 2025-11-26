#!/usr/bin/env python3
"""
Test script for Image Generation API
Run this to verify your backend is working before enabling in Flutter
"""
import requests
import json
import sys

# Backend URL
BASE_URL = "http://127.0.0.1:8000"
API_ENDPOINT = f"{BASE_URL}/api/v1/generate/image"

def test_health():
    """Test if backend is running"""
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        if response.status_code == 200:
            print("✅ Backend is running")
            return True
        else:
            print(f"❌ Backend returned status {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to backend")
        print("💡 Start backend: uvicorn app.main:app --reload")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_image_generation(auth_token=None):
    """Test image generation endpoint"""
    print("\n🧪 Testing Image Generation API...")
    
    # Request payload (matches ImageGenerationRequest schema)
    payload = {
        "prompt": "Flutter logo in office of pakistan",
        "size": "1024x1024",
        "style": "realistic",
        "aspect_ratio": "1:1",
        "enhance_prompt": True
    }
    
    # Headers
    headers = {
        "Content-Type": "application/json",
    }
    
    if auth_token:
        headers["Authorization"] = f"Bearer {auth_token}"
    
    try:
        print(f"📤 POST {API_ENDPOINT}")
        print(f"📝 Payload: {json.dumps(payload, indent=2)}")
        
        response = requests.post(
            API_ENDPOINT,
            json=payload,
            headers=headers,
            timeout=30  # Flux Schnell takes 2-3 seconds
        )
        
        print(f"📥 Status: {response.status_code}")
        
        if response.status_code == 401:
            print("❌ 401 Unauthorized - Authentication required")
            print("💡 This endpoint requires a valid Firebase auth token")
            print("💡 Get token from Flutter app or Firebase console")
            return False
        
        if response.status_code == 402:
            print("❌ 402 Payment Required - Quota exceeded")
            data = response.json()
            print(f"💡 {data.get('detail', {}).get('message', 'Check your subscription')}")
            return False
        
        if response.status_code == 201:
            data = response.json()
            print("✅ Image generated successfully!")
            print(f"")
            print(f"📊 Response:")
            print(f"   Model: {data.get('model')}")
            print(f"   Generation Time: {data.get('generation_time')}s")
            print(f"   Cost: ${data.get('cost')}")
            print(f"   Size: {data.get('size')}")
            print(f"   Quality: {data.get('quality')}")
            print(f"")
            print(f"🖼️  Image URL:")
            print(f"   {data.get('image_url')[:100]}...")
            print(f"")
            print(f"📝 Prompt Used:")
            print(f"   {data.get('prompt_used')[:100]}...")
            return True
        
        print(f"❌ Unexpected status: {response.status_code}")
        print(f"Response: {response.text}")
        return False
        
    except requests.exceptions.Timeout:
        print("❌ Request timeout (>30s)")
        print("💡 Check if Replicate API token is valid")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    """Run tests"""
    print("=" * 60)
    print("Image Generation API Test")
    print("=" * 60)
    
    # Test 1: Backend health
    if not test_health():
        sys.exit(1)
    
    # Test 2: Image generation (without auth - will fail)
    print("\n" + "=" * 60)
    print("Testing without authentication (expected to fail)")
    print("=" * 60)
    test_image_generation()
    
    # Instructions
    print("\n" + "=" * 60)
    print("Next Steps:")
    print("=" * 60)
    print("1. ✅ Backend is running correctly")
    print("2. ⚠️  API requires Firebase authentication")
    print("3. 💡 To test with auth:")
    print("   - Get Firebase ID token from Flutter app")
    print("   - Run: python test_image_api.py <your-token>")
    print("4. 💡 Or test through Flutter app:")
    print("   - Set _useMockData = false in image_generation_service.dart")
    print("   - Login to app and generate an image")
    print("   - Check Flutter console for API logs")
    print("=" * 60)

if __name__ == "__main__":
    # Check if token provided
    auth_token = sys.argv[1] if len(sys.argv) > 1 else None
    
    if auth_token:
        print("🔐 Using provided auth token")
    
    main()
