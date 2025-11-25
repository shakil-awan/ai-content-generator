#!/usr/bin/env python3
"""
Quick test script for ad copy endpoint
"""
import requests
import json

BASE_URL = "http://localhost:8001"

def test_ad_copy_generation():
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
    
    print("\n📢 Step 2: Testing ad copy generation...")
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    ad_request = {
        "product_service": "Online Fitness Training Platform",
        "target_audience": "Busy professionals aged 25-45",
        "unique_selling_point": "Personalized workouts that fit any schedule",
        "platform": "facebook",
        "campaign_goal": "conversions",
        "tone": "inspirational"
    }
    
    print(f"Request: {json.dumps(ad_request, indent=2)}")
    
    ad_response = requests.post(
        f"{BASE_URL}/api/v1/generate/ad",
        headers=headers,
        json=ad_request
    )
    
    print(f"\n📊 Response Status: {ad_response.status_code}")
    
    if ad_response.status_code == 201:
        result = ad_response.json()
        print("✅ Ad copy generation successful!")
        print(f"\nGeneration ID: {result.get('id')}")
        print(f"Title/Headline: {result.get('title')}")
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
        print(f"❌ Ad copy generation failed!")
        print(f"Response: {ad_response.text}")
        return False

if __name__ == "__main__":
    success = test_ad_copy_generation()
    exit(0 if success else 1)
