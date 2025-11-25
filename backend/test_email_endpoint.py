#!/usr/bin/env python3
"""
Quick test script for email generation endpoint
"""
import requests
import json

BASE_URL = "http://localhost:8001"

def test_email_generation():
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
    
    print("\n📧 Step 2: Testing email generation...")
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    email_request = {
        "campaign_type": "promotional",
        "subject_line": "Exclusive Summer Sale - 50% Off",
        "product_service": "Premium subscription service",
        "tone": "friendly",
        "include_personalization": True
    }
    
    print(f"Request: {json.dumps(email_request, indent=2)}")
    
    email_response = requests.post(
        f"{BASE_URL}/api/v1/generate/email",
        headers=headers,
        json=email_request
    )
    
    print(f"\n📊 Response Status: {email_response.status_code}")
    
    if email_response.status_code == 200:
        result = email_response.json()
        print("✅ Email generation successful!")
        print(f"\nGeneration ID: {result.get('id')}")
        print(f"Title/Subject: {result.get('title')}")
        print(f"Content Preview: {result.get('content')[:200]}...")
        print(f"Quality Score: {result.get('quality_score')}")
    else:
        print(f"❌ Email generation failed!")
        print(f"Response: {email_response.text}")

if __name__ == "__main__":
    test_email_generation()
