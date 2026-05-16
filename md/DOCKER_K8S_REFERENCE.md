# 🐳 Docker & Kubernetes Quick Reference

## Docker Commands for Local Testing

### Build Images Locally
```bash
# Build backend image
docker build -t signature-backend:latest ./backend

# Build frontend image
docker build -t signature-frontend:latest ./frontend

# List images
docker images
```

### Run Containers Locally
```bash
# Run backend
docker run -p 5000:5000 \
  -e DATABASE_URL="mysql+mysqlconnector://signature_user:signature_pass@mysql-service:3306/signature_db" \
  signature-backend:latest

# Run frontend
docker run -p 80:80 signature-frontend:latest
```

### Push to Google Container Registry
```bash
# Tag images
docker tag signature-backend:latest gcr.io/PROJECT_ID/signature-backend:latest
docker tag signature-frontend:latest gcr.io/PROJECT_ID/signature-frontend:latest

# Push to GCR
docker push gcr.io/PROJECT_ID/signature-backend:latest
docker push gcr.io/PROJECT_ID/signature-frontend:latest

# Verify push
gcloud container images list
```

### Docker Compose (Local Testing with MySQL)
```bash
# This still works!
docker-compose up -d

# Verify containers
docker-compose ps

# Stop
docker-compose down
```

---

## Kubernetes Commands

### Cluster Management
```bash
# Get cluster info
kubectl cluster-info
kubectl get nodes
kubectl describe node <NODE_NAME>

# Create cluster (GKE)
gcloud container clusters create my-cluster --region us-central1

# Get credentials
gcloud container clusters get-credentials my-cluster
```

### Namespace Operations
```bash
# Create namespace
kubectl create namespace signature-app

# List namespaces
kubectl get namespaces

# Set default namespace
kubectl config set-context --current --namespace=signature-app

# Delete namespace (WARNING: deletes everything in it!)
kubectl delete namespace signature-app
```

### Deployments
```bash
# Create deployment
kubectl create deployment backend --image=gcr.io/PROJECT_ID/signature-backend:latest -n signature-app

# Apply YAML manifests
kubectl apply -f k8s/backend.yaml

# View deployments
kubectl get deployments -n signature-app
kubectl describe deployment backend -n signature-app

# Scale deployment
kubectl scale deployment backend --replicas=3

# Rollout status
kubectl rollout status deployment/backend

# Rollout history
kubectl rollout history deployment/backend

# Rollback to previous version
kubectl rollout undo deployment/backend

# Update image
kubectl set image deployment/backend backend=gcr.io/PROJECT_ID/signature-backend:v2
```

### Pods
```bash
# List pods
kubectl get pods -n signature-app

# Detailed pod info
kubectl describe pod <POD_NAME> -n signature-app

# View pod logs
kubectl logs <POD_NAME> -n signature-app
kubectl logs -f <POD_NAME> -n signature-app  # Follow logs

# Execute command in pod
kubectl exec -it <POD_NAME> -n signature-app -- /bin/bash

# Port forward
kubectl port-forward <POD_NAME> 8080:80 -n signature-app

# Delete pod (will be recreated)
kubectl delete pod <POD_NAME> -n signature-app

# Get pod events
kubectl describe pod <POD_NAME> -n signature-app | grep -A 20 Events:
```

### Services
```bash
# List services
kubectl get svc -n signature-app

# Describe service
kubectl describe svc backend-service -n signature-app

# Get service details
kubectl get svc backend-service -n signature-app -o wide

# Port forward via service
kubectl port-forward svc/backend-service 5000:5000 -n signature-app

# Get LoadBalancer IP
kubectl get svc frontend-service -n signature-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

### ConfigMaps & Secrets
```bash
# View ConfigMaps
kubectl get configmap -n signature-app
kubectl describe configmap signature-app-config -n signature-app

# View Secrets
kubectl get secrets -n signature-app
kubectl describe secret signature-app-secret -n signature-app

# Create ConfigMap
kubectl create configmap my-config --from-literal=key=value -n signature-app

# Create Secret
kubectl create secret generic my-secret --from-literal=password=secret -n signature-app

# Edit ConfigMap
kubectl edit configmap signature-app-config -n signature-app
```

### Horizontal Pod Autoscaling
```bash
# View HPA status
kubectl get hpa -n signature-app
kubectl describe hpa backend-hpa -n signature-app

# Manually create HPA
kubectl autoscale deployment backend --min=2 --max=5 --cpu-percent=70 -n signature-app

# Watch HPA scaling
kubectl get hpa -n signature-app --watch
```

### Monitoring & Logs
```bash
# Resource usage (requires metrics-server)
kubectl top pods -n signature-app
kubectl top nodes

# Get events
kubectl get events -n signature-app
kubectl get events -n signature-app --sort-by='.lastTimestamp'

# Tail logs from all pods of a deployment
kubectl logs -l app=backend -n signature-app --all-containers=true -f

# Get logs from previous crashed container
kubectl logs <POD_NAME> --previous -n signature-app
```

### Debugging
```bash
# Get detailed pod status
kubectl describe pod <POD_NAME> -n signature-app

# Check liveness/readiness probes
kubectl get pod <POD_NAME> -n signature-app -o yaml | grep -A 10 livenessProbe

# Debug with temporary pod
kubectl run -it --rm debug --image=ubuntu --overrides='{"spec":{"serviceAccountName":"default"}}' -- bash

# Check DNS resolution
kubectl run -it --rm testpod --image=busybox -- nslookup mysql-service.signature-app.svc.cluster.local

# Test backend connectivity
kubectl run -it --rm testpod --image=curlimages/curl -- curl http://backend-service.signature-app.svc.cluster.local:5000/api/health
```

---

## YAML Management

### Validate YAML
```bash
kubectl apply -f k8s/backend.yaml --dry-run=client

# Validate all YAML files
for f in k8s/*.yaml; do kubectl apply -f $f --dry-run=client; done
```

### Apply/Update Resources
```bash
# Apply single file
kubectl apply -f k8s/backend.yaml

# Apply all files in directory
kubectl apply -f k8s/

# Apply with specific namespace
kubectl apply -f k8s/backend.yaml -n signature-app

# Apply and watch rollout
kubectl apply -f k8s/backend.yaml && kubectl rollout status deployment/backend
```

### View Resource YAML
```bash
# Get current YAML
kubectl get deployment backend -n signature-app -o yaml

# Different output formats
kubectl get deployment -n signature-app -o json
kubectl get deployment -n signature-app -o wide
```

### Delete Resources
```bash
# Delete single resource
kubectl delete deployment backend -n signature-app

# Delete multiple resources
kubectl delete -f k8s/backend.yaml -f k8s/frontend.yaml

# Delete all resources in namespace
kubectl delete all -n signature-app

# Force delete (use with caution)
kubectl delete pod <POD_NAME> --grace-period=0 --force
```

---

## GCloud Integration

### Container Registry (GCR)
```bash
# Configure docker auth
gcloud auth configure-docker

# Push to GCR
docker tag signature-backend:latest gcr.io/PROJECT_ID/signature-backend:latest
docker push gcr.io/PROJECT_ID/signature-backend:latest

# List images
gcloud container images list

# Get image details
gcloud container images describe gcr.io/PROJECT_ID/signature-backend:latest

# Scan for vulnerabilities
gcloud container images scan gcr.io/PROJECT_ID/signature-backend:latest
```

### GKE Operations
```bash
# Create cluster
gcloud container clusters create my-cluster --num-nodes=3 --region=us-central1

# List clusters
gcloud container clusters list

# Get credentials (authenticate kubectl)
gcloud container clusters get-credentials my-cluster --region us-central1

# Delete cluster
gcloud container clusters delete my-cluster --region us-central1

# Resize cluster
gcloud container clusters update my-cluster --num-nodes=5

# Get cluster info
gcloud container clusters describe my-cluster
```

### Cloud Build
```bash
# Submit build manually
gcloud builds submit --config=cloudbuild.yaml

# List builds
gcloud builds list

# Get build logs
gcloud builds log <BUILD_ID> --stream

# View build details
gcloud builds describe <BUILD_ID>

# Create trigger from command line
gcloud builds triggers create github --name=my-trigger --repo-owner=username --repo-name=repo --branch-pattern="^main$"
```

---

## Useful Aliases

Add to your `.bashrc` or `.zshrc`:

```bash
# Kubernetes aliases
alias k='kubectl'
alias kn='kubectl config set-context --current --namespace'
alias kgp='kubectl get pods'
alias kgd='kubectl get deployments'
alias kgs='kubectl get svc'
alias kl='kubectl logs'
alias kd='kubectl describe'
alias kex='kubectl exec -it'

# GCloud aliases
alias gk='gcloud container'
alias ggp='gcloud config get-value project'
alias gsp='gcloud config set-value project'

# Docker aliases
alias dc='docker container'
alias di='docker image'
alias dr='docker run'
```

Usage:
```bash
k get pods -n signature-app
kgd
kl backend-pod -n signature-app
```

---

## Useful Links

- Kubernetes Cheatsheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- GKE Best Practices: https://cloud.google.com/kubernetes-engine/docs/best-practices
- Docker Reference: https://docs.docker.com/reference/
- Cloud Build: https://cloud.google.com/build/docs
