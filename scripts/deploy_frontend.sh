#!/bin/bash
# Deploy Flutter Web to Firebase Hosting
# Usage: ./scripts/deploy_frontend.sh [environment]
# Example: ./scripts/deploy_frontend.sh production

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default environment
ENVIRONMENT=${1:-production}

echo -e "${BLUE}🚀 Deploying Flutter Web to Firebase Hosting${NC}"
echo -e "${BLUE}🌍 Environment: $ENVIRONMENT${NC}"
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Firebase CLI not found${NC}"
    echo -e "${YELLOW}Install it with: npm install -g firebase-tools${NC}"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo -e "${RED}❌ Not logged in to Firebase${NC}"
    echo -e "${YELLOW}Login with: firebase login${NC}"
    exit 1
fi

# Build the web app
echo -e "${YELLOW}📦 Building Flutter web app...${NC}"
./scripts/build_web.sh $ENVIRONMENT

# Deploy to Firebase Hosting
echo -e "${YELLOW}🚀 Deploying to Firebase Hosting...${NC}"
firebase deploy --only hosting

echo ""
echo -e "${GREEN}✅ Deployment complete!${NC}"
echo -e "${GREEN}🌐 Your app is live at:${NC}"
echo -e "   ${BLUE}https://ai-content-generator-7ec6a.web.app${NC}"
echo -e "   ${BLUE}https://ai-content-generator-7ec6a.firebaseapp.com${NC}"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo -e "  1. Test the deployed app"
echo -e "  2. Monitor in Firebase Console: https://console.firebase.google.com"
echo -e "  3. Check analytics and errors"
