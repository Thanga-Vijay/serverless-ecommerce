#!/bin/bash
# Complete Project Setup Script

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   Serverless E-Commerce Platform - Complete Setup             ║"
echo "╚════════════════════════════════════════════════════════════════╝"

# Set error handling
set -e

PROJECT_ROOT=$(pwd)
FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKEND_DIR="$PROJECT_ROOT/backend"
INFRA_DIR="$PROJECT_ROOT/infrastructure"

echo ""
echo "📦 Installing Frontend Dependencies..."
cd "$FRONTEND_DIR"
npm install
echo "✓ Frontend dependencies installed"

echo ""
echo "📦 Installing Backend Shared Utilities..."
cd "$BACKEND_DIR"
npm install
echo "✓ Backend root dependencies installed"

echo ""
echo "📦 Installing Auth Service..."
cd "$BACKEND_DIR/auth-service"
npm install
echo "✓ Auth service installed"

echo ""
echo "🏗️  Infrastructure Setup (Terraform)..."
cd "$INFRA_DIR/terraform"
echo "Run 'terraform plan' to review infrastructure changes:"
echo "  cd infrastructure/terraform"
echo "  terraform init"
echo "  terraform plan -var='environment=dev'"
echo "  terraform apply -var='environment=dev'"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                 ✅ SETUP COMPLETE                             ║"
echo "╚════════════════════════════════════════════════════════════════╝"

echo ""
echo "📋 NEXT STEPS:"
echo ""
echo "1️⃣  Frontend Development:"
echo "   cd frontend"
echo "   npm run dev"
echo "   Visit: http://localhost:5173"
echo ""
echo "2️⃣  Backend Local Development:"
echo "   cd backend"
echo "   serverless offline start"
echo "   API running on: http://localhost:3000"
echo ""
echo "3️⃣  Infrastructure Deployment:"
echo "   cd infrastructure/terraform"
echo "   terraform init"
echo "   terraform plan -var='environment=dev'"
echo "   terraform apply -var='environment=dev'"
echo ""
echo "4️⃣  Check Configuration Files:"
echo "   - frontend/.env.development     (API URL, Cognito settings)"
echo "   - frontend/.env.production      (Production settings)"
echo "   - backend/.env.dev              (Database, SQS, SNS config)"
echo "   - infrastructure/terraform/terraform.tfvars"
echo ""
echo "📚 Documentation:"
echo "   - API_URL_SETUP.md               (Environment variable guide)"
echo "   - backend/ARCHITECTURE.md        (System design)"
echo "   - backend/SETUP.md              (Backend setup guide)"
echo "   - README.md                     (Project overview)"
echo ""
echo "🚀 CI/CD:"
echo "   - .github/workflows/frontend.yml (Frontend pipeline)"
echo "   - .github/workflows/backend.yml  (Backend pipeline)"
echo "   - .github/workflows/terraform.yml (Infrastructure pipeline)"
echo ""
