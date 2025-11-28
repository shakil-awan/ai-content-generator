#!/bin/bash
# Build Flutter Web for Production
# Usage: ./scripts/build_web.sh [environment]
# Example: ./scripts/build_web.sh production

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default environment
ENVIRONMENT=${1:-production}

# API URLs by environment
case $ENVIRONMENT in
  production)
    API_URL="https://ai-content-generator-api.onrender.com"
    ;;
  staging)
    API_URL="https://ai-content-generator-staging.onrender.com"
    ;;
  development)
    API_URL="http://127.0.0.1:8000"
    ;;
  *)
    echo -e "${YELLOW}⚠️  Unknown environment: $ENVIRONMENT${NC}"
    echo "Using production settings..."
    API_URL="https://ai-content-generator-api.onrender.com"
    ;;
esac

echo -e "${BLUE}🏗️  Building Flutter Web for $ENVIRONMENT${NC}"
echo -e "${BLUE}🔗 API URL: $API_URL${NC}"

# Clean previous build
echo -e "${YELLOW}🧹 Cleaning previous build...${NC}"
flutter clean

# Get dependencies
echo -e "${YELLOW}📦 Getting dependencies...${NC}"
flutter pub get

# Build for web with environment variables
echo -e "${YELLOW}🔨 Building web app...${NC}"
flutter build web \
  --release \
  --web-renderer canvaskit \
  --dart-define=ENVIRONMENT=$ENVIRONMENT \
  --dart-define=API_URL=$API_URL

echo -e "${GREEN}✅ Build complete!${NC}"
echo -e "${GREEN}📁 Output: build/web/${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Test locally: ${YELLOW}cd build/web && python3 -m http.server 8080${NC}"
echo -e "  2. Deploy: ${YELLOW}firebase deploy --only hosting${NC}"
