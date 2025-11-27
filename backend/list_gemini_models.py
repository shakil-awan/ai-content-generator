#!/usr/bin/env python3
"""
Check available Gemini models
"""
import os
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

print("📋 Available Gemini Models:\n")
for model in genai.list_models():
    if 'generateContent' in model.supported_generation_methods:
        print(f"  ✅ {model.name}")
        if "2.5" in model.name or "2.0" in model.name or "flash" in model.name:
            print(f"     → {model.display_name}")

print("\n💡 Recommended models:")
print("  • gemini-2.0-flash-exp (FREE, best for development)")
print("  • gemini-1.5-flash (PAID, production-ready)")
print("  • gemini-1.5-pro (PAID, premium quality)")
