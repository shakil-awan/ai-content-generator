#!/bin/bash
# Quick deployment script for both backend and frontend
# Usage: ./scripts/deploy_all.sh

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   🚀 AI Content Generator - Full Deployment${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# Step 1: Deploy Frontend
echo -e "${YELLOW}Step 1/2: Deploying Frontend to Firebase Hosting...${NC}"
./scripts/deploy_frontend.sh production

echo ""
echo -e "${GREEN}✅ Frontend deployed successfully!${NC}"
echo ""

# Step 2: Backend Deployment Instructions
echo -e "${YELLOW}Step 2/2: Backend Deployment${NC}"
echo -e "${BLUE}Backend is deployed on Render.com${NC}"
echo ""
echo -e "To update backend:"
echo -e "  1. Push changes to GitHub: ${YELLOW}git push origin main${NC}"
echo -e "  2. Render will auto-deploy from GitHub"
echo -e "  3. Or manually deploy from: ${BLUE}https://dashboard.render.com${NC}"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}   ✅ Deployment Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}🌐 Your App URLs:${NC}"
echo -e "   Frontend: ${GREEN}https://ai-content-generator-7ec6a.web.app${NC}"
echo -e "   Backend:  ${GREEN}https://ai-content-generator-api.onrender.com${NC}"
echo -e "   API Docs: ${GREEN}https://ai-content-generator-api.onrender.com/docs${NC}"
