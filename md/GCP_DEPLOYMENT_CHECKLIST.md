# ☁️ GCP Deployment - Quick Start Checklist

Before running the deployment script, make sure you have:

## ✅ Prerequisites

- [ ] **Google Cloud Account** - Create at https://cloud.google.com
- [ ] **GCP Project** - Create a new project or use existing
- [ ] **Billing Enabled** - Enable billing for your project
- [ ] **Google Cloud SDK (gcloud)** - https://cloud.google.com/sdk/docs/install
- [ ] **kubectl** - https://kubernetes.io/docs/tasks/tools/
- [ ] **Docker** - https://docs.docker.com/get-docker/

## 🎯 Step-by-Step Guide

### Step 1: Setup GCP Account & Project
```bash
# 1. Go to https://console.cloud.google.com
# 2. Create new project
# 3. Note your PROJECT_ID
# 4. Enable billing
```

### Step 2: Install Required Tools

**Windows:**
```powershell
# Install Google Cloud SDK
# Download: https://cloud.google.com/sdk/docs/install

# Install kubectl (via gcloud)
gcloud components install kubectl

# Docker Desktop for Windows
# Download: https://docs.docker.com/desktop/install/windows-install/
```

**Mac/Linux:**
```bash
# Install Google Cloud SDK
curl https://sdk.cloud.google.com | bash

# Install kubectl
gcloud components install kubectl

# Install Docker
# Follow: https://docs.docker.com/get-docker/
```

### Step 3: Authenticate with GCP
```bash
# Login with your Google account
gcloud auth login

# Verify authentication
gcloud config list
```

### Step 4: Run Deployment Script

**On Windows:**
```powershell
cd C:\Users\Phyoe\Desktop\test\signature-app

# Run deployment script (you'll be prompted for Project ID)
.\deploy-to-gcp.bat
```

**On Mac/Linux:**
```bash
cd ~/signature-app

# Make script executable
chmod +x deploy-to-gcp.sh

# Run deployment
./deploy-to-gcp.sh
```

### Step 5: Wait for Deployment
The script will:
1. ✓ Enable necessary GCP APIs
2. ✓ Build Docker images
3. ✓ Push to Google Container Registry
4. ✓ Create GKE Kubernetes cluster (5-10 minutes)
5. ✓ Deploy MySQL database
6. ✓ Deploy backend application
7. ✓ Deploy frontend application
8. ✓ Configure load balancer and get external IP

### Step 6: Access Your App
Once deployment completes, you'll get:
```
Your application is now running!

Access your app at:
http://<EXTERNAL_IP>
```

Open that URL in your browser and start using the app!

---

## 📊 What Gets Created

```
GCP Project
├── Cloud Build (for CI/CD)
├── Container Registry (gcr.io)
│   ├── signature-backend:latest
│   └── signature-frontend:latest
└── GKE Cluster (signature-app-cluster)
    ├── 3 nodes (auto-scales 1-5)
    ├── Namespace: signature-app
    ├── MySQL Pod (1 replica)
    ├── Backend Pods (2-5 replicas, auto-scaling)
    ├── Frontend Pods (2-5 replicas, auto-scaling)
    └── Load Balancer (External IP)
```

---

## 💰 Estimated Costs

**Monthly estimate** (us-central1):
- 3x n1-standard-1 nodes: ~$50-100
- Load Balancer: ~$1.50
- MySQL storage: ~$1
- Container Registry storage: ~$0.02

**Total: ~$50-100/month** (can be reduced by using preemptible VMs)

---

## 🔍 Monitor Your Deployment

### View Cluster Status
```bash
gcloud container clusters describe signature-app-cluster
```

### View Running Pods
```bash
kubectl get pods -n signature-app
kubectl get svc -n signature-app
```

### View Logs
```bash
# Backend logs
kubectl logs -f deployment/backend -n signature-app

# Frontend logs
kubectl logs -f deployment/frontend -n signature-app

# MySQL logs
kubectl logs deployment/mysql -n signature-app
```

### Monitor in Google Cloud Console
https://console.cloud.google.com
- Kubernetes Engine → Workloads
- Kubernetes Engine → Services & Ingress
- Cloud Logging for detailed logs
- Cloud Monitoring for metrics

---

## 🚀 Next: Setup CI/CD

After deployment, setup automatic deployment on code push:

```bash
# Push code to GitHub
git push origin main

# In Cloud Console:
# 1. Go to Cloud Build → Triggers
# 2. Click "Create Trigger"
# 3. Connect GitHub
# 4. Set: cloudbuild.yaml as build configuration
# 5. Automatic deployment on every push!
```

---

## ⚠️ Troubleshooting

### Script fails: "gcloud not found"
- Install Google Cloud SDK from https://cloud.google.com/sdk/docs/install
- Restart terminal/PowerShell

### "Project not found" error
- Verify your GCP Project ID is correct
- Project ID ≠ Project Name (check in Cloud Console)

### Cluster creation takes too long
- This is normal! First cluster creation takes 5-10 minutes
- Check progress in Cloud Console → Kubernetes Engine → Clusters

### LoadBalancer pending external IP
- This is normal! LoadBalancer takes 2-5 minutes to assign IP
- Script will wait and retrieve it automatically

### Pods not starting
```bash
# Describe failed pod
kubectl describe pod <POD_NAME> -n signature-app

# Check events
kubectl get events -n signature-app

# Check logs
kubectl logs <POD_NAME> -n signature-app
```

---

## 🧹 Cleanup (Stop Charges)

When done learning/testing, delete everything:

```bash
# Delete GKE cluster (this deletes everything!)
gcloud container clusters delete signature-app-cluster --region us-central1

# Delete Container Registry images
gcloud container images delete gcr.io/PROJECT_ID/signature-backend:latest
gcloud container images delete gcr.io/PROJECT_ID/signature-frontend:latest

# Verify everything is deleted
gcloud container clusters list
gcloud container images list
```

---

## 📞 Still Having Issues?

1. **Check GCP Console**: https://console.cloud.google.com for real-time status
2. **View logs**: Kubernetes Engine → Workloads → Select pod → Logs tab
3. **Check deployment status**:
   ```bash
   kubectl describe deployment backend -n signature-app
   ```
4. **Read the full guide**: See `GCP_DEPLOYMENT.md` for detailed steps

---

**Ready to deploy? Run the deployment script!** 🚀

Windows:
```powershell
.\deploy-to-gcp.bat
```

Mac/Linux:
```bash
./deploy-to-gcp.sh
```

Good luck! 🎉
