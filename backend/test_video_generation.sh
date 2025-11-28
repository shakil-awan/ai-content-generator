#!/bin/bash

# ================================================================
# Video Generation Testing Script
# Tests the complete video generation workflow from script to video
# ================================================================

set -e  # Exit on error

echo "🎬 VIDEO GENERATION TESTING SCRIPT"
echo "====================================="
echo ""

# Configuration
BASE_URL="${API_URL:-http://localhost:8000}"
TOKEN="${AUTH_TOKEN:-}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if token is provided
if [ -z "$TOKEN" ]; then
    echo -e "${RED}❌ ERROR: AUTH_TOKEN environment variable not set${NC}"
    echo ""
    echo "Usage:"
    echo "  export AUTH_TOKEN='your-jwt-token-here'"
    echo "  ./test_video_generation.sh"
    echo ""
    echo "Or inline:"
    echo "  AUTH_TOKEN='your-token' ./test_video_generation.sh"
    exit 1
fi

echo -e "${BLUE}📍 API Base URL: $BASE_URL${NC}"
echo ""

# ================================================================
# STEP 1: Generate Video Script
# ================================================================

echo -e "${YELLOW}Step 1: Generating video script...${NC}"
echo ""

SCRIPT_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/generate/video-script" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "5 Tips for Better Productivity with AI",
    "platform": "youtube",
    "duration": 60,
    "target_audience": "Professionals aged 25-40",
    "tone": "professional",
    "include_hooks": true,
    "include_cta": true,
    "key_points": [
      "Use AI for task automation",
      "AI-powered note-taking",
      "Smart scheduling assistants"
    ]
  }')

# Check if request was successful
if echo "$SCRIPT_RESPONSE" | grep -q '"id"'; then
    GENERATION_ID=$(echo "$SCRIPT_RESPONSE" | jq -r '.id')
    echo -e "${GREEN}✅ Script generated successfully!${NC}"
    echo -e "${BLUE}   Generation ID: $GENERATION_ID${NC}"
    echo ""
    
    # Show script preview
    echo -e "${YELLOW}   Script Preview:${NC}"
    echo "$SCRIPT_RESPONSE" | jq -r '.content' | head -n 5
    echo "   ..."
    echo ""
else
    echo -e "${RED}❌ Script generation failed!${NC}"
    echo "$SCRIPT_RESPONSE" | jq '.'
    exit 1
fi

# ================================================================
# STEP 2: Generate Video from Script
# ================================================================

echo -e "${YELLOW}Step 2: Generating video from script...${NC}"
echo -e "${BLUE}   This will take 60-90 seconds...${NC}"
echo ""

VIDEO_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/generate/video-from-script" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"generation_id\": \"$GENERATION_ID\",
    \"voice_style\": \"natural\",
    \"music_mood\": \"upbeat\",
    \"video_style\": \"modern\",
    \"include_captions\": true
  }")

# Check if request was successful
if echo "$VIDEO_RESPONSE" | grep -q '"id"'; then
    VIDEO_JOB_ID=$(echo "$VIDEO_RESPONSE" | jq -r '.id')
    VIDEO_URL=$(echo "$VIDEO_RESPONSE" | jq -r '.video_url')
    PROCESSING_TIME=$(echo "$VIDEO_RESPONSE" | jq -r '.processing_time')
    COST=$(echo "$VIDEO_RESPONSE" | jq -r '.cost')
    
    echo -e "${GREEN}✅ Video generated successfully!${NC}"
    echo -e "${BLUE}   Video Job ID: $VIDEO_JOB_ID${NC}"
    echo -e "${BLUE}   Processing Time: ${PROCESSING_TIME}s${NC}"
    echo -e "${BLUE}   Cost: \$$COST${NC}"
    echo -e "${GREEN}   Video URL: $VIDEO_URL${NC}"
    echo ""
else
    echo -e "${RED}❌ Video generation failed!${NC}"
    echo "$VIDEO_RESPONSE" | jq '.'
    exit 1
fi

# ================================================================
# STEP 3: Check Video Status
# ================================================================

echo -e "${YELLOW}Step 3: Checking video status...${NC}"
echo ""

STATUS_RESPONSE=$(curl -s -X GET "$BASE_URL/api/v1/generate/video-status/$VIDEO_JOB_ID" \
  -H "Authorization: Bearer $TOKEN")

if echo "$STATUS_RESPONSE" | grep -q '"id"'; then
    STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.status')
    PROGRESS=$(echo "$STATUS_RESPONSE" | jq -r '.progress')
    
    echo -e "${GREEN}✅ Status retrieved successfully!${NC}"
    echo -e "${BLUE}   Status: $STATUS${NC}"
    echo -e "${BLUE}   Progress: $PROGRESS%${NC}"
    echo ""
else
    echo -e "${RED}❌ Status check failed!${NC}"
    echo "$STATUS_RESPONSE" | jq '.'
    exit 1
fi

# ================================================================
# SUMMARY
# ================================================================

echo ""
echo "================================================================"
echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
echo "================================================================"
echo ""
echo "Summary:"
echo "  ✅ Script Generation: $GENERATION_ID"
echo "  ✅ Video Generation: $VIDEO_JOB_ID"
echo "  ✅ Status Check: $STATUS ($PROGRESS%)"
echo "  ✅ Processing Time: ${PROCESSING_TIME}s"
echo "  ✅ Cost: \$$COST"
echo ""
echo -e "${GREEN}Video URL:${NC} $VIDEO_URL"
echo ""
echo "Next steps:"
echo "  1. Open the video URL in your browser to view"
echo "  2. Test in the Flutter app UI"
echo "  3. Verify video quality and captions"
echo ""

# Save results to file
RESULTS_FILE="test_results_$(date +%Y%m%d_%H%M%S).json"
cat > "$RESULTS_FILE" <<EOF
{
  "test_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "generation_id": "$GENERATION_ID",
  "video_job_id": "$VIDEO_JOB_ID",
  "video_url": "$VIDEO_URL",
  "processing_time": $PROCESSING_TIME,
  "cost": $COST,
  "status": "$STATUS",
  "progress": $PROGRESS
}
EOF

echo -e "${BLUE}📄 Results saved to: $RESULTS_FILE${NC}"
echo ""
