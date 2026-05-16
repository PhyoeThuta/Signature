# 🚀 GCP Deployment Guide - CI/CD & Kubernetes

This guide walks you through deploying the Signature App to Google Cloud Platform with CI/CD and Kubernetes.

## 📋 Prerequisites

- Google Cloud Project (create at https://cloud.google.com)
- `gcloud` CLI installed (https://cloud.google.com/sdk/docs/install)
- `kubectl` installed (https://kubernetes.io/docs/tasks/tools/)
- `docker` installed
- Git repository pushed to GitHub/GitLab
- Domain name (optional, for Ingress)

---

## 🎯 Architecture

```
Your Local Machine
     ↓
   GitHub (Push code)
     ↓
Cloud Build (Auto-triggers on push)
     ↓
Build Docker Images
     ↓
Push to Google Container Registry
     ↓
Deploy to GKE Cluster
     ↓
     ├── Frontend (Nginx) on Load Balancer
     ├── Backend (Flask) on Service
     └── MySQL Database on Persistent Volume
```

---

## 📝 Step-by-Step Deployment

### Step 1: Setup GCP Project

```bash
# Set your project ID
export PROJECT_ID="your-project-id"
export REGION="us-central1"
export CLUSTER_NAME="signature-app-cluster"

# Authenticate with GCP
gcloud auth login

# Set default project
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable \
  container.googleapis.com \
  containerregistry.googleapis.com \
  cloudbuild.googleapis.com \
  compute.googleapis.com \
  servicenetworking.googleapis.com
```

### Step 2: Create GKE Cluster

```bash
# Create Kubernetes cluster (3 nodes)
gcloud container clusters create $CLUSTER_NAME \
  --region $REGION \
  --num-nodes 3 \
  --machine-type n1-standard-1 \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 5 \
  --enable-autorepair \
  --enable-autoupgrade

# Get cluster credentials
gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION

# Verify cluster connection
kubectl cluster-info
kubectl get nodes
```

### Step 3: Create Container Registry

```bash
# Enable Container Registry (uses Cloud Storage)
gcloud services enable containerregistry.googleapis.com

# Configure Docker to authenticate with GCR
gcloud auth configure-docker
```

### Step 4: Deploy MySQL Database (First Time Only)

```bash
# Navigate to project root
cd signature-app

# Create namespace and MySQL
kubectl apply -f k8s/namespace-config.yaml
kubectl apply -f k8s/mysql.yaml

# Wait for MySQL to be ready
kubectl wait --for=condition=ready pod -l app=mysql -n signature-app --timeout=300s

# Verify MySQL is running
kubectl get pods -n signature-app
kubectl logs -n signature-app deployment/mysql
```

### Step 5: Push Code to GitHub

```bash
# Initialize git (if not already done)
cd signature-app
git init
git add .
git commit -m "Initial commit: Signature app with Docker and Kubernetes"

# Add remote and push
git remote add origin https://github.com/YOUR_USERNAME/signature-app.git
git branch -M main
git push -u origin main
```

### Step 6: Setup Cloud Build CI/CD

```bash
# Create Cloud Build trigger to auto-deploy on push

# Using gcloud CLI:
gcloud builds triggers create github \
  --name="signature-app-deploy" \
  --repo-name="signature-app" \
  --repo-owner="YOUR_GITHUB_USERNAME" \
  --branch-pattern="^main$" \
  --build-config="cloudbuild.yaml" \
  --substitutions="_CLUSTER_NAME=$CLUSTER_NAME,_CLUSTER_REGION=$REGION"
```

Or use Cloud Console:
1. Go to Cloud Build → Triggers
2. Click "Create Trigger"
3. Select GitHub as source
4. Connect your repo
5. Set branch pattern: `^main$`
6. Set build configuration: `cloudbuild.yaml`

### Step 7: Deploy Initial Manifests

```bash
# Apply Kubernetes manifests (update PROJECT_ID in yaml files first)
sed -i "s/PROJECT_ID/$PROJECT_ID/g" k8s/backend.yaml
sed -i "s/PROJECT_ID/$PROJECT_ID/g" k8s/frontend.yaml

# Deploy backend and frontend
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml

# Check deployments
kubectl get deployments -n signature-app
kubectl get pods -n signature-app
kubectl get svc -n signature-app
```

### Step 8: Get External IP

```bash
# Wait for LoadBalancer to get external IP
kubectl get svc frontend-service -n signature-app -w

# Once you see external IP, access your app:
# http://<EXTERNAL_IP>
```

### Step 9: Setup Custom Domain (Optional)

```bash
# Reserve static IP
gcloud compute addresses create signature-app-ip --global

# Get the IP
gcloud compute addresses describe signature-app-ip --global

# Point your domain to this IP in DNS settings

# Update ingress.yaml with your domain
# Then apply:
kubectl apply -f k8s/ingress.yaml
```

---

## 🔄 CI/CD Pipeline Explanation

### What Happens When You Push Code:

1. **Push to GitHub**
   ```bash
   git add .
   git commit -m "Update backend code"
   git push origin main
   ```

2. **Cloud Build Automatically Triggers**
   - Reads `cloudbuild.yaml`
   - Builds Docker images
   - Runs tests (optional)
   - Pushes images to GCR

3. **Automatic Deployment**
   - Updates Kubernetes deployments
   - Rolls out new images
   - Automatic health checks
   - Rollback on failure (optional)

### View Build Logs:
```bash
# In Cloud Console
gcloud builds log <BUILD_ID> --stream

# Or in Google Cloud Console:
# Cloud Build → History
```

---

## 📊 Monitoring Your Deployment

### Check Pod Status
```bash
# All pods
kubectl get pods -n signature-app

# Detailed info
kubectl describe pod <POD_NAME> -n signature-app

# Logs
kubectl logs <POD_NAME> -n signature-app

# Real-time logs
kubectl logs -f <POD_NAME> -n signature-app

# All logs from deployment
kubectl logs -l app=backend -n signature-app --all-containers=true
```

### Check Services
```bash
# All services
kubectl get svc -n signature-app

# Get external IP
kubectl get svc frontend-service -n signature-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

### Check HPA (Auto-scaling)
```bash
# View HPA status
kubectl get hpa -n signature-app

# Detailed HPA info
kubectl describe hpa backend-hpa -n signature-app
```

### View Events
```bash
# Recent events
kubectl get events -n signature-app

# Watch events in real-time
kubectl get events -n signature-app --watch
```

---

## 🔧 Common Kubernetes Commands

```bash
# Port forward to test backend locally
kubectl port-forward svc/backend-service 5000:5000 -n signature-app

# Port forward to test frontend locally
kubectl port-forward svc/frontend-service 8080:80 -n signature-app

# Scale deployment
kubectl scale deployment backend --replicas=3 -n signature-app

# Rollout history
kubectl rollout history deployment/backend -n signature-app

# Rollback to previous version
kubectl rollout undo deployment/backend -n signature-app

# Force restart deployment
kubectl rollout restart deployment/backend -n signature-app

# Execute command in pod
kubectl exec -it <POD_NAME> -n signature-app -- /bin/bash

# Delete entire namespace (WARNING: deletes everything)
kubectl delete namespace signature-app
```

---

## 🐛 Troubleshooting

### Pod not starting
```bash
kubectl describe pod <POD_NAME> -n signature-app
# Look for events section and error messages
```

### ImagePullBackOff error
```bash
# Check if image exists in Container Registry
gcloud container images list

# Check authentication
gcloud auth configure-docker
```

### Database connection error
```bash
# Check if MySQL pod is running
kubectl get pod -l app=mysql -n signature-app

# View MySQL logs
kubectl logs -l app=mysql -n signature-app

# Test connection from backend pod
kubectl exec -it <BACKEND_POD> -n signature-app -- \
  python -c "import mysql.connector; print('Connected!')"
```

### Out of memory/CPU
```bash
# Check resource usage
kubectl top pods -n signature-app
kubectl top nodes

# Increase resource limits in deployment yaml
# or scale up nodes:
gcloud container clusters update $CLUSTER_NAME --num-nodes 5
```

---

## 💰 Cost Optimization

```bash
# Use preemptible nodes (70% cheaper, but can be interrupted)
gcloud container node-pools create preemptible-pool \
  --cluster=$CLUSTER_NAME \
  --preemptible

# Set resource requests properly
# - Makes scheduling more efficient
# - Prevents over-provisioning

# Use cluster autoscaling
# - Already enabled in setup
# - Automatically scales nodes based on demand

# Monitor costs
gcloud compute billing-accounts list
gcloud billing accounts describe <ACCOUNT_ID>
```

---

## 🔐 Security Best Practices

```bash
# 1. Use Secrets for sensitive data (not ConfigMaps)
kubectl create secret generic db-secret \
  --from-literal=password=secure-password \
  -n signature-app

# 2. Use Network Policies to restrict traffic
kubectl apply -f k8s/network-policies.yaml

# 3. Enable Pod Security Policies
kubectl apply -f k8s/pod-security-policies.yaml

# 4. Use private container registry
# Set imagePullPolicy: IfNotPresent
# Pull images only when needed

# 5. Scan images for vulnerabilities
gcloud container images scan <IMAGE_URL>
```

---

## 📈 Scaling & Performance

### Horizontal Pod Autoscaling (Already Enabled)
- Min 2 replicas, Max 5
- Scales based on CPU (70%) and Memory (80%)

### Manual Scaling
```bash
# Scale backend to 5 replicas
kubectl scale deployment backend --replicas=5 -n signature-app

# Scale frontend
kubectl scale deployment frontend --replicas=5 -n signature-app
```

### Monitoring with Google Cloud Monitoring
```bash
# View in Cloud Console
# Monitoring → Dashboards
# Create custom dashboard for your app
```

---

## ✅ Deployment Checklist

- [ ] GCP Project created and APIs enabled
- [ ] GKE cluster created (3+ nodes)
- [ ] MySQL deployed and verified
- [ ] Code pushed to GitHub
- [ ] Cloud Build trigger configured
- [ ] Docker images built and pushed to GCR
- [ ] Backend deployed to Kubernetes
- [ ] Frontend deployed to Kubernetes
- [ ] External IP assigned to frontend
- [ ] Application accessible via browser
- [ ] Database persisting data
- [ ] Auto-scaling working
- [ ] Logs and monitoring setup
- [ ] Custom domain configured (optional)

---

## 🎓 Learning Resources

- GKE Docs: https://cloud.google.com/kubernetes-engine/docs
- Kubernetes: https://kubernetes.io/docs
- Cloud Build: https://cloud.google.com/build/docs
- Dockerfile best practices: https://docs.docker.com/develop/dev-best-practices/

---

## 🎉 Next Steps

1. **Monitor your app** in Cloud Console
2. **Setup alerts** for errors and high resource usage
3. **Implement logging** with Cloud Logging
4. **Add more features** and practice CI/CD deployments
5. **Practice scaling** and performance testing

---

**Your app is now in production! 🚀**

Push code → Cloud Build builds → Automatic deployment to Kubernetes!
