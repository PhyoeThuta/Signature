# 🎯 Complete GCP Deployment & CI/CD Learning Path

## What You Now Have

You've created a production-ready application with complete Dockerization and Kubernetes setup for GCP!

### 📦 What's Included

```
signature-app/
├── Dockerfile (Backend)
├── frontend/Dockerfile (Frontend - multi-stage)
├── frontend/nginx.conf (Web server config)
├── .dockerignore (both)
├── cloudbuild.yaml (CI/CD pipeline)
├── k8s/
│   ├── namespace-config.yaml
│   ├── mysql.yaml
│   ├── backend.yaml
│   ├── frontend.yaml
│   └── ingress.yaml
├── GCP_DEPLOYMENT.md
├── DOCKER_K8S_REFERENCE.md
└── (existing source code)
```

---

## 🚀 Quick Start Path

### Phase 1: Local Docker Testing
```bash
# Build images locally
docker build -t signature-backend:latest backend/
docker build -t signature-frontend:latest frontend/

# Verify they work
docker run -p 5000:5000 signature-backend:latest
docker run -p 80:80 signature-frontend:latest
```

### Phase 2: Push to GCP
```bash
# Setup
export PROJECT_ID="your-project-id"
gcloud auth configure-docker
gcloud config set project $PROJECT_ID

# Tag images
docker tag signature-backend:latest gcr.io/$PROJECT_ID/signature-backend:latest
docker tag signature-frontend:latest gcr.io/$PROJECT_ID/signature-frontend:latest

# Push
docker push gcr.io/$PROJECT_ID/signature-backend:latest
docker push gcr.io/$PROJECT_ID/signature-frontend:latest
```

### Phase 3: Create GKE Cluster
```bash
# Create cluster
gcloud container clusters create signature-app-cluster \
  --region us-central1 \
  --num-nodes 3

# Get credentials
gcloud container clusters get-credentials signature-app-cluster --region us-central1

# Verify
kubectl get nodes
```

### Phase 4: Deploy to Kubernetes
```bash
# Update images in k8s/* files
sed -i "s/PROJECT_ID/$PROJECT_ID/g" k8s/*.yaml

# Deploy everything
kubectl apply -f k8s/namespace-config.yaml
kubectl apply -f k8s/mysql.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml

# Wait for deployment
kubectl get pods -n signature-app -w

# Get external IP
kubectl get svc frontend-service -n signature-app
```

### Phase 5: Setup CI/CD
```bash
# Push code to GitHub
git push origin main

# Setup Cloud Build trigger
# (See GCP_DEPLOYMENT.md for detailed steps)
```

---

## 📚 Learning Resources

### Docker Concepts
- **Dockerfile**: Instructions to build image
- **Image**: Template/snapshot of app
- **Container**: Running instance of image
- **Registry**: Repository for images (GCR)
- **Multi-stage build**: Optimize image size (frontend)

### Kubernetes Concepts
- **Pod**: Smallest unit, container wrapper
- **Deployment**: Manages replicasets and rollouts
- **Service**: Network access to pods
- **Namespace**: Virtual clusters
- **ConfigMap**: Configuration data
- **Secret**: Sensitive data
- **PersistentVolume**: Storage
- **HPA**: Auto-scaling based on metrics

### CI/CD Concepts
- **Cloud Build**: Automated build service
- **Trigger**: Event-based build execution
- **Pipeline**: Steps: build → test → push → deploy
- **Rollout**: Safe deployment strategy

---

## 🎓 Practice Exercises

### Exercise 1: Local Docker
**Goal**: Build and run containers locally

```bash
# 1. Build backend image
docker build -t signature-backend:v1 backend/

# 2. Run with MySQL
docker-compose up -d mysql
docker run -p 5000:5000 \
  -e DATABASE_URL="mysql+mysqlconnector://signature_user:signature_pass@localhost:3306/signature_db" \
  signature-backend:v1

# 3. Test API
curl http://localhost:5000/api/health

# 4. Build frontend
docker build -t signature-frontend:v1 frontend/
docker run -p 3000:3000 signature-frontend:v1

# 5. Test in browser: http://localhost:3000
```

### Exercise 2: Push to Registry
**Goal**: Push images to Google Container Registry

```bash
# 1. Configure Docker
gcloud auth configure-docker

# 2. Tag images
docker tag signature-backend:v1 gcr.io/PROJECT_ID/signature-backend:v1
docker tag signature-frontend:v1 gcr.io/PROJECT_ID/signature-frontend:v1

# 3. Push
docker push gcr.io/PROJECT_ID/signature-backend:v1
docker push gcr.io/PROJECT_ID/signature-frontend:v1

# 4. Verify
gcloud container images list
gcloud container images describe gcr.io/PROJECT_ID/signature-backend:v1
```

### Exercise 3: Local Kubernetes
**Goal**: Run Kubernetes locally (requires minikube)

```bash
# 1. Install minikube
# (See https://minikube.sigs.k8s.io/docs/start/)

# 2. Start minikube
minikube start

# 3. Deploy MySQL
kubectl apply -f k8s/mysql.yaml

# 4. Wait for MySQL
kubectl wait --for=condition=ready pod -l app=mysql --timeout=300s

# 5. Deploy backend (use local images)
kubectl set image deployment/backend backend=signature-backend:v1 --local -o yaml | kubectl apply -f -

# 6. Check status
kubectl get pods
kubectl logs deployment/mysql
```

### Exercise 4: GKE Deployment
**Goal**: Deploy to actual GKE cluster

```bash
# 1. Create cluster
gcloud container clusters create signature-app --region us-central1 --num-nodes 3

# 2. Get credentials
gcloud container clusters get-credentials signature-app

# 3. Deploy
kubectl apply -f k8s/

# 4. Monitor
kubectl get pods -w
kubectl get svc

# 5. Access app
EXTERNAL_IP=$(kubectl get svc frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "App running at http://$EXTERNAL_IP"
```

### Exercise 5: CI/CD Pipeline
**Goal**: Setup automated deployment

```bash
# 1. Push code to GitHub
git push origin main

# 2. Create Cloud Build trigger
gcloud builds triggers create github \
  --name="auto-deploy" \
  --repo-name="signature-app" \
  --branch-pattern="^main$" \
  --build-config="cloudbuild.yaml"

# 3. Make a change and push
echo "# Updated!" >> README.md
git add .
git commit -m "Test CI/CD"
git push origin main

# 4. Watch build
gcloud builds list --limit=1
gcloud builds log <BUILD_ID> --stream

# 5. Verify deployment
kubectl get pods -w
kubectl get svc frontend-service
```

---

## 🔑 Key Files Explained

### backend/Dockerfile
```dockerfile
# Lightweight Python base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies and Flask app
# Exposes port 5000
# Health check included
# Starts Flask server
```

### frontend/Dockerfile
```dockerfile
# Stage 1: Build React
FROM node:18-alpine AS builder
# npm install && npm build
# Creates optimized /build folder

# Stage 2: Serve with Nginx
FROM nginx:alpine
# Copies built app
# Configures Nginx
# Exposes port 80
# Much smaller final image!
```

### k8s/backend.yaml
- **Deployment**: 2 replicas of backend
- **Service**: ClusterIP for internal access
- **HPA**: Auto-scales to 5 replicas on high load
- **Env vars**: From ConfigMap and Secrets
- **Probes**: Liveness & readiness checks

### k8s/frontend.yaml
- **Deployment**: 2 replicas of frontend
- **Service**: LoadBalancer (gets external IP)
- **HPA**: Auto-scales to 5 replicas
- **Health check**: HTTP endpoint

### cloudbuild.yaml
```yaml
# Steps:
# 1. Build backend image
# 2. Build frontend image
# 3. Push backend to GCR
# 4. Push frontend to GCR
# 5. Update backend deployment
# 6. Update frontend deployment
# 7. Verify rollout

# Triggers on: git push to main branch
# Runs on: Cloud Build servers
# Deploys to: GKE cluster
```

---

## 📊 Architecture Visualization

```
GitHub Repository
       ↓
   [main branch]
       ↓
Cloud Build (Triggered automatically)
       ↓
    ┌──────────────┬──────────────┐
    ↓              ↓              ↓
 Build        Build            Test
Firebase     Frontend        (optional)
Image         Image
    │              │              │
    └──────────────┼──────────────┘
       ↓           ↓           ↓
   GCR (Google Container Registry)
       
       ↓
   
   Deployment Update
       ↓
   ┌──────────────┬──────────────┐
   ↓              ↓              ↓
GKE Cluster
  ├── Frontend (2+ pods, auto-scales)
  ├── Backend (2+ pods, auto-scales)
  └── MySQL (1 pod, persistent volume)
  
  Load Balancer
       ↓
  External IP
       ↓
      Users
```

---

## ✅ Kubernetes Best Practices

### What I've Included

✅ **Resource Limits**: CPU and memory limits
✅ **Health Checks**: Liveness and readiness probes
✅ **Auto-scaling**: HPA configured
✅ **Persistent Storage**: MySQL uses PersistentVolume
✅ **Namespaces**: Isolated environment
✅ **Secrets**: Sensitive data protected
✅ **Stateless Frontend**: Easily scalable
✅ **Multi-replica**: No single point of failure

### What You Should Add

⚠️ **Network Policies**: Restrict traffic between pods
⚠️ **Pod Security Policies**: Restrict pod capabilities
⚠️ **Resource Quotas**: Limit namespace resources
⚠️ **Monitoring**: Prometheus + Grafana
⚠️ **Logging**: Cloud Logging integration
⚠️ **Backup**: MySQL backup strategy
⚠️ **SSL/TLS**: HTTPS certificates

---

## 🔧 Troubleshooting Quick Tips

### Debugging Workflow
```bash
# 1. Check pod status
kubectl get pods -n signature-app

# 2. Describe failing pod
kubectl describe pod <POD_NAME> -n signature-app

# 3. Check logs
kubectl logs <POD_NAME> -n signature-app

# 4. Check events
kubectl get events -n signature-app

# 5. Port forward and test
kubectl port-forward <POD_NAME> 8080:80 -n signature-app
curl http://localhost:8080

# 6. Execute shell in pod
kubectl exec -it <POD_NAME> -n signature-app -- /bin/bash
```

### Common Issues

| Issue | Solution |
|-------|----------|
| ImagePullBackOff | Check if image exists in GCR, verify auth |
| CrashLoopBackOff | Check pod logs, verify environment variables |
| Pending pods | Check resource availability, node capacity |
| Connection refused | Verify service discovery, DNS names |
| Database won't connect | Check MySQL pod, network policies, secrets |

---

## 🎓 Next Learning Steps

1. **Add monitoring**: Prometheus + Grafana
2. **Add logging**: Cloud Logging + Cloud Trace
3. **Setup alerts**: Alert on high CPU/memory
4. **Implement security**: Network policies, Pod security
5. **Add backup/restore**: MySQL backup strategy
6. **Multi-region deployment**: Deploy to multiple regions
7. **Service mesh**: Istio for advanced routing
8. **GitOps**: FluxCD or ArgoCD for declarative deployments

---

## 📞 Quick Reference

### Useful Commands
```bash
# Check everything
kubectl get all -n signature-app

# Follow all logs
kubectl logs -f deployment/backend -n signature-app

# Watch deployment
kubectl rollout status deployment/backend -n signature-app

# Scale manually
kubectl scale deployment backend --replicas=5

# Update image
kubectl set image deployment/backend backend=gcr.io/$PROJECT_ID/signature-backend:new-tag

# Shell into pod
kubectl exec -it <POD> -n signature-app -- /bin/bash
```

### GCP Commands
```bash
# Set project
gcloud config set project PROJECT_ID

# Build manually
gcloud builds submit --config=cloudbuild.yaml

# View builds
gcloud builds list

# View registry
gcloud container images list
```

---

## 🎉 Summary

You now have:
✅ Dockerized backend and frontend
✅ Kubernetes manifests for production deployment
✅ CI/CD pipeline with Cloud Build
✅ Auto-scaling configured
✅ Health checks and monitoring
✅ Complete GCP deployment guide
✅ Learning resources and best practices

**Next:** Follow GCP_DEPLOYMENT.md to deploy your app! 🚀

---

**Version**: 1.0.0  
**Created**: March 2024  
**For**: Learning GCP, Docker, Kubernetes & CI/CD
