#!/bin/bash

#  Signature App - Complete GCP Deployment Script
# This script automates the entire deployment process to GCP

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ==================== CONFIGURATION ====================
PROJECT_ID="${GCP_PROJECT_ID:-}"
REGION="us-central1"
CLUSTER_NAME="signature-app-cluster"
DOCKER_REGISTRY="gcr.io"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🚀 Signature App - GCP Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# ==================== STEP 1: VERIFY PREREQUISITES ====================
echo -e "${YELLOW}[Step 1/8] Checking prerequisites...${NC}"

check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 not installed. Please install it first.${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ $1 found${NC}"
    fi
}

check_command "gcloud"
check_command "kubectl"
check_command "docker"
echo ""

# ==================== STEP 2: GET PROJECT ID ====================
echo -e "${YELLOW}[Step 2/8] Setting up GCP Project...${NC}"

if [ -z "$PROJECT_ID" ]; then
    echo "Enter your GCP Project ID:"
    read PROJECT_ID
fi

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}❌ Project ID is required${NC}"
    exit 1
fi

export PROJECT_ID=$PROJECT_ID
gcloud config set project $PROJECT_ID
echo -e "${GREEN}✓ Project set to: $PROJECT_ID${NC}"
echo ""

# ==================== STEP 3: ENABLE APIS ====================
echo -e "${YELLOW}[Step 3/8] Enabling required GCP APIs...${NC}"

gcloud services enable \
  container.googleapis.com \
  containerregistry.googleapis.com \
  cloudbuild.googleapis.com \
  compute.googleapis.com \
  servicenetworking.googleapis.com \
  2>/dev/null || true

echo -e "${GREEN}✓ APIs enabled${NC}"
echo ""

# ==================== STEP 4: BUILD DOCKER IMAGES ====================
echo -e "${YELLOW}[Step 4/8] Building Docker images...${NC}"

echo "Building backend image..."
docker build -t signature-backend:latest ./backend
docker tag signature-backend:latest $DOCKER_REGISTRY/$PROJECT_ID/signature-backend:latest

echo "Building frontend image..."
docker build -t signature-frontend:latest ./frontend
docker tag signature-frontend:latest $DOCKER_REGISTRY/$PROJECT_ID/signature-frontend:latest

echo -e "${GREEN}✓ Docker images built${NC}"
echo ""

# ==================== STEP 5: CONFIGURE DOCKER AUTH ====================
echo -e "${YELLOW}[Step 5/8] Configuring Docker authentication...${NC}"

gcloud auth configure-docker
echo -e "${GREEN}✓ Docker authenticated with GCP${NC}"
echo ""

# ==================== STEP 6: PUSH IMAGES TO GCR ====================
echo -e "${YELLOW}[Step 6/8] Pushing images to Google Container Registry...${NC}"

echo "Pushing backend image..."
docker push $DOCKER_REGISTRY/$PROJECT_ID/signature-backend:latest

echo "Pushing frontend image..."
docker push $DOCKER_REGISTRY/$PROJECT_ID/signature-frontend:latest

echo -e "${GREEN}✓ Images pushed to GCR${NC}"
echo ""

# ==================== STEP 7: CREATE/CHECK GKE CLUSTER ====================
echo -e "${YELLOW}[Step 7/8] Creating GKE cluster...${NC}"

if gcloud container clusters describe $CLUSTER_NAME --region $REGION &>/dev/null; then
    echo -e "${BLUE}Cluster already exists. Using existing cluster.${NC}"
else
    echo "Creating new cluster (this may take 5-10 minutes)..."
    gcloud container clusters create $CLUSTER_NAME \
      --region $REGION \
      --num-nodes 3 \
      --machine-type n1-standard-1 \
      --enable-autoscaling \
      --min-nodes 1 \
      --max-nodes 5 \
      --enable-autorepair \
      --enable-autoupgrade \
      --addons GcePersistentDiskCsiDriver
fi

gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION
echo -e "${GREEN}✓ GKE cluster ready${NC}"
echo ""

# ==================== STEP 8: DEPLOY TO KUBERNETES ====================
echo -e "${YELLOW}[Step 8/8] Deploying to Kubernetes...${NC}"

# Update image references in k8s files
sed -i.bak "s|gcr.io/PROJECT_ID|$DOCKER_REGISTRY/$PROJECT_ID|g" k8s/backend.yaml k8s/frontend.yaml

# Create namespace and secrets
echo "Creating namespace and configuration..."
kubectl apply -f k8s/namespace-config.yaml

# Deploy MySQL
echo "Deploying MySQL database..."
kubectl apply -f k8s/mysql.yaml

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql -n signature-app --timeout=300s || true
sleep 5

# Deploy backend and frontend
echo "Deploying backend..."
kubectl apply -f k8s/backend.yaml

echo "Deploying frontend..."
kubectl apply -f k8s/frontend.yaml

echo -e "${GREEN}✓ Deployment complete${NC}"
echo ""

# ==================== VERIFY DEPLOYMENT ====================
echo -e "${YELLOW}Verifying deployment...${NC}"

kubectl wait --for=condition=ready pod -l app=backend -n signature-app --timeout=300s || true
kubectl wait --for=condition=ready pod -l app=frontend -n signature-app --timeout=300s || true

echo ""
echo -e "${GREEN}✓ All pods are running!${NC}"
echo ""

# ==================== GET ACCESS INFO ====================
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}🎉 DEPLOYMENT SUCCESSFUL!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo "Getting external IP (this may take a minute)..."
EXTERNAL_IP=$(kubectl get svc frontend-service -n signature-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)

while [ -z "$EXTERNAL_IP" ] || [ "$EXTERNAL_IP" = "<pending>" ]; do
    echo "Waiting for LoadBalancer IP..."
    sleep 5
    EXTERNAL_IP=$(kubectl get svc frontend-service -n signature-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
done

echo ""
echo -e "${GREEN}✓ Your application is now running!${NC}"
echo ""
echo -e "${BLUE}Access your app at:${NC}"
echo -e "${YELLOW}http://$EXTERNAL_IP${NC}"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo "  View pods:     kubectl get pods -n signature-app"
echo "  View services: kubectl get svc -n signature-app"
echo "  View logs:     kubectl logs -f deployment/backend -n signature-app"
echo "  Scale backend: kubectl scale deployment backend --replicas=5 -n signature-app"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Open browser: http://$EXTERNAL_IP"
echo "2. Register a user"
echo "3. Create and sign a form"
echo "4. Check GCP Console for monitoring: https://console.cloud.google.com"
echo ""
