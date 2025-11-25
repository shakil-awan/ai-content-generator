#!/usr/bin/env python3
"""
Quick test script for product description endpoint
"""
import requests
import json

BASE_URL = "http://localhost:8001"

def test_product_generation():
    print("🔐 Step 1: Logging in...")
    login_response = requests.post(
        f"{BASE_URL}/api/v1/auth/login",
        json={
            "email": "user@example.com",
            "password": "SecurePass123!"
        }
    )
    
    if login_response.status_code != 200:
        print(f"❌ Login failed: {login_response.status_code}")
        print(login_response.text)
        return
    
    token_data = login_response.json()
    access_token = token_data.get('access_token')
    print(f"✅ Login successful! Token: {access_token[:20]}...")
    
    print("\n📦 Step 2: Testing product description generation...")
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    product_request = {
        "product_name": "Premium Wireless Headphones",
        "category": "Electronics",
        "key_features": ["Noise cancellation", "30-hour battery", "Bluetooth 5.0"],
        "benefits": ["Crystal clear sound", "All-day comfort", "Wireless freedom"],
        "target_audience": "Music lovers and professionals",
        "tone": "professional",
        "platform": "ecommerce",
        "include_seo": True
    }
    
    print(f"Request: {json.dumps(product_request, indent=2)}")
    
    product_response = requests.post(
        f"{BASE_URL}/api/v1/generate/product",
        headers=headers,
        json=product_request
    )
    
    print(f"\n📊 Response Status: {product_response.status_code}")
    
    if product_response.status_code == 201:
        result = product_response.json()
        print("✅ Product description generation successful!")
        print(f"\nGeneration ID: {result.get('id')}")
        print(f"Title: {result.get('title')}")
        print(f"Content Length: {len(result.get('content', ''))} characters")
        print(f"Content Preview: {result.get('content', '')[:300]}...")
        print(f"Quality Score: {result.get('quality_metrics', {}).get('overall_score', 0)}")
        
        # Check if content and title are not empty
        if result.get('content') and result.get('title'):
            print("\n✅ SUCCESS: Both content and title are populated!")
            return True
        else:
            print(f"\n❌ FAILURE: Content empty: {not result.get('content')}, Title empty: {not result.get('title')}")
            return False
    else:
        print(f"❌ Product generation failed!")
        print(f"Response: {product_response.text}")
        return False

if __name__ == "__main__":
    success = test_product_generation()
    exit(0 if success else 1)
