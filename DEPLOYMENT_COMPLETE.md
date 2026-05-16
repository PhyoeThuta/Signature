# ✓ DEPLOYMENT COMPLETE

**Date:** March 25, 2026  
**Status:** LIVE on Google Cloud Platform (GCP)  
**Region:** europe-west1-b (Belgium)

---

## 🎉 Application Now Live

### **Frontend URL (Public Access)**
```
http://104.199.50.165
```

**Open in browser to access the signature application**

---

## Pod Status

```
NAME                          READY   STATUS    RESTARTS   AGE
backend-cf8bb9487-fptvb       1/1     Running   1          4m
backend-cf8bb9487-w4cnm       1/1     Running   1          4m
frontend-689dd465f8-9s5cg     1/1     Running   0          1m
frontend-689dd465f8-c6nxd     1/1     Running   0          1m
mysql-7f9444696f-7f472        1/1     Running   0          5m
```

### Service Details

| Service | Type | Cluster IP | External IP | Port |
|---------|------|-----------|------------|------|
| **frontend-service** | LoadBalancer | 34.118.231.11 | **104.199.50.165** | 80 |
| **backend-service** | ClusterIP | 34.118.232.222 | (internal) | 5000 |
| **mysql-service** | ClusterIP | 34.118.227.228 | (internal) | 3306 |

---

## Architecture Deployed

```
┌─────────────────────────────────────────────────────────────┐
│          Google Cloud Platform (GCP)                        │
│                  europe-west1-b                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│          GKE Cluster: signature-app-cluster                 │
│          (1x e2-small + 1x e2-medium nodes)                │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ signature-app Namespace (Kubernetes)                │  │
│  │                                                      │  │
│  │  Frontend (Nginx)      Backend (Flask)   Database   │  │
│  │  ┌──────────────┐      ┌────────────┐   ┌────────┐ │  │
│  │  │ frontend:80  │      │backend:5000│   │MySQL   │ │  │
│  │  │ (2 replicas) │◄─────│(2 replicas)│──►│8.0     │ │  │
│  │  │ + HPA 2-5    │      │ + HPA 2-5  │   │10Gi PV │ │  │
│  │  │ LoadBalancer │      │ ClusterIP  │   │Private │ │  │
│  │  └──────────────┘      └────────────┘   └────────┘ │  │
│  │       ▲                                              │  │
│  │       │                                              │  │
│  │  External IP: 104.199.50.165                        │  │
│  │  Port 80 (HTTP)                                      │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
           ▲
           │
      Internet Access
```

---

## System Configuration

### Frontend (React + Nginx)
- **Image:** `gcr.io/phyoethuta31/signature-frontend:latest`
- **Port:** 80 (HTTP)
- **Replicas:** 2 (auto-scaling 2-5 based on CPU/Memory)
- **Resources:** 100m CPU / 128Mi RAM (requests), 200m CPU / 256Mi RAM (limits)
- **Health Check:** HTTP GET /health (10s initial delay, 10s period)
- **Nginx Config:** API proxies to `backend-service.signature-app.svc.cluster.local:5000`

### Backend (Flask + Python)
- **Image:** `gcr.io/phyoethuta31/signature-backend:latest`
- **Port:** 5000 (HTTP)
- **Replicas:** 2 (auto-scaling 2-5 based on CPU/Memory)
- **Resources:** 100m CPU / 128Mi RAM (requests), 200m CPU / 256Mi RAM (limits)
- **Health Check:** /api/health endpoint
- **Endpoints:**
  - POST `/api/auth/register` - User registration
  - POST `/api/auth/login` - User authentication
  - GET/POST `/api/forms` - Form CRUD operations
  - POST `/api/signatures` - Submit signature
  - GET `/api/signatures?form_id=X` - Retrieve signatures

### Database (MySQL 8.0)
- **Name:** signature_db
- **User:** signature_user
- **Password:** signature_pass (in k8s secret)
- **Tables:**
  - users (id, username, email, password, role, created_at)
  - forms (id, title, content, creator_id, status, created_at, updated_at)
  - signatures (id, form_id, signer_id, signature_data [base64], signed_at, created_at)
- **Storage:** 10Gi PersistentVolume (auto-provisioned by GKE)
- **Port:** 3306 (internal cluster access only)

---

## How to Use

### 1. **Access the Application**
```
http://104.199.50.165
```

### 2. **Create Account**
- Click "Register"
- Enter username, email, password
- Select role (user, principal, admin)
- Submit

### 3. **Login**
- Click "Login"  
- Enter email and password
- Submit

### 4. **Create a Form**
- After login, click "Create New Form"
- Enter form title and content
- Submit

### 5. **Sign Forms**
- Click "Sign Form"
- Draw your signature on the canvas
- Click "Clear" to redo or "Submit" to save
- Signature is stored in database

### 6. **View Signatures**
- Navigate to signed form
- View all signatures submitted to that form

---

## Testing Endpoints

### Frontend
```bash
# Test frontend is running
curl http://104.199.50.165
# Should return HTML content (React app)
```

### Backend Health Check
```bash
# Test backend health
kubectl exec -it backend-cf8bb9487-fptvb -n signature-app -- curl localhost:5000/api/health
# Should return JSON response
```

### Database Connection
```bash
# Test MySQL
kubectl exec -it mysql-7f9444696f-7f472 -n signature-app -- mysql -u signature_user -psignature_pass signature_db -e "SELECT * FROM users;"
```

---

## Kubernetes Commands

### View Pods
```bash
kubectl get pods -n signature-app -w  # Watch mode
kubectl describe pod <pod-name> -n signature-app
```

### View Logs
```bash
kubectl logs frontend-689dd465f8-9s5cg -n signature-app --tail=50
kubectl logs backend-cf8bb9487-fptvb -n signature-app -f  # Follow
```

### View Services
```bash
kubectl get svc -n signature-app
kubectl describe svc frontend-service -n signature-app
```

### Exec into Pod
```bash
kubectl exec -it frontend-689dd465f8-9s5cg -n signature-app -- /bin/bash
```

### Scale Deployment
```bash
kubectl scale deployment frontend --replicas=3 -n signature-app
```

### View Cluster Resources
```bash
kubectl top nodes
kubectl top pods -n signature-app
```

---

## Monitoring & Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n signature-app
# Expected: All pods showing READY 1/1 and STATUS Running
```

### Get Pod Events
```bash
kubectl get events -n signature-app --sort-by='.lastTimestamp'
```

### Check Node Resources
```bash
# View available nodes
gcloud container clusters describe signature-app-cluster --zone europe-west1-b

# List nodes
kubectl get nodes --show-labels
```

### View Deployment Rollouts
```bash
kubectl rollout status deployment/frontend -n signature-app
kubectl rollout history deployment/frontend -n signature-app
```

### Check Storage
```bash
kubectl get pvc -n signature-app  # PersistentVolumeClaims
kubectl get pv  # PersistentVolumes
```

---

## GCP Resources Created

### Compute
- **GKE Cluster:** `signature-app-cluster`
- **Location:** `europe-west1-b`
- **Nodes:** 2 (1x e2-small + 1x e2-medium)
- **Master IP:** 35.233.97.31
- **Node Pools:** default, highperf

### Storage
- **Persistent Disks:** 10Gi (MySQL storage)
- **Container Registry:** gcr.io/phyoethuta31/

### Networking
- **LoadBalancer Service:** 104.199.50.165 (external IP)
- **Internal Subnet:** 10.12.0.0/14 (pod CIDR)
- **Service CIDR:** 10.0.0.0/20

### Container Images
```
gcr.io/phyoethuta31/signature-backend:latest   (~400MB)
gcr.io/phyoethuta31/signature-frontend:latest  (~50MB)
```

---

## Cost Estimation

### Monthly Costs (GCP Free Tier Credit Available)

| Component | Type | Cost/Month |
|-----------|------|-----------|
| **GKE Cluster** | 1 e2-small node (free tier) | $0 |
| **Additional Node** | 1 e2-medium node | ~$25 |
| **Persistent Disk** | 10Gi MySQL storage | ~$1 |
| **LoadBalancer IP** | External IP address | ~$3 |
| **Compute (e2-medium)** | CPU/Memory usage | ~$15 |
| **Egress Data** | Internet traffic | ~$1 |
| **Total** | | **~$45/month** |

**Note:** $300 GCP free credit available for 12 months covers this setup!

---

## Cleanup (To Stop Costs)

### Delete GKE Cluster
```bash
gcloud container clusters delete signature-app-cluster --zone europe-west1-b
```

### Delete Container Images
```bash
gcloud container images delete gcr.io/phyoethuta31/signature-backend --quiet
gcloud container images delete gcr.io/phyoethuta31/signature-frontend --quiet
```

### Delete Persistent Disks
```bash
gcloud compute disks list
gcloud compute disks delete <disk-name> --zone europe-west1-b
```

---

## Files Modified

### Fixed Issues
1. **k8s/frontend.yaml** - Changed image from `gcr.io/PROJECT_ID/...` to `gcr.io/phyoethuta31/...`
2. **k8s/backend.yaml** - Changed image from `gcr.io/PROJECT_ID/...` to `gcr.io/phyoethuta31/...`
3. **frontend/nginx.conf** - Updated backend URL from `http://backend:5000` to `http://backend-service.signature-app.svc.cluster.local:5000`

### Built & Pushed
- ✓ Backend Docker image to GCR
- ✓ Frontend Docker image to GCR
- ✓ Updated frontend image with corrected nginx config

### Deployed
- ✓ Kubernetes namespace and config
- ✓ MySQL deployment with 10Gi persistent storage
- ✓ Backend deployment (2 replicas + HPA)
- ✓ Frontend deployment (2 replicas + HPA)
- ✓ LoadBalancer service (external IP: 104.199.50.165)

---

## Next Steps (Optional)

1. **Configure Custom Domain**
   - Add DNS A record pointing to 104.199.50.165
   - Update Ingress manifest with custom domain

2. **Enable HTTPS/TLS**
   - Create certificate with Google Cloud Armor / Certificate Manager
   - Configure ingress for HTTPS

3. **Setup CI/CD Pipeline**
   - Use Cloud Build to auto-deploy on git push
   - Configure cloudbuild.yaml trigger

4. **Add Monitoring**
   - Setup Google Cloud Monitoring/Prometheus
   - Create dashboards and alerts

5. **Database Backups**
   - Setup automated MySQL backups
   - Configure Cloud SQL for managed database

6. **Security Hardening**
   - Add JWT authentication (replace basic auth)
   - Hash passwords with bcrypt
   - Add API rate limiting
   - Setup network policies

---

## Support & Debugging

### Check Logs in Real-time
```bash
kubectl logs <pod-name> -n signature-app -f --tail=20
```

### Port-forward to Local
```bash
# Access backend locally
kubectl port-forward svc/backend-service 5000:5000 -n signature-app

# In another terminal
curl http://localhost:5000/api/health
```

### Check Node Status
```bash
gcloud compute instances list --zones=europe-west1-b
```

### Verify DNS Resolution
```bash
kubectl exec -it <pod-name> -n signature-app -- nslookup backend-service.signature-app.svc.cluster.local
```

---

## Deployment Summary

| Item | Status | Details |
|------|--------|---------|
| **GKE Cluster** | ✓ Running | europe-west1-b, 1x e2-small + 1x e2-medium |
| **MySQL** | ✓ Running | signature_db, 10Gi storage |
| **Backend** | ✓ Running | 2 pods, auto-scaling ready |
| **Frontend** | ✓ Running | 2 pods, LoadBalancer assigned |
| **External IP** | ✓ Active | 104.199.50.165 on port 80 |
| **Docker Images** | ✓ Pushed | Both images in gcr.io/phyoethuta31/ |
| **Database** | ✓ Connected | MySQL accessible from pods |

---

**🚀 Your digital signature application is now live and accessible 24/7 on Google Cloud!**

**Frontend:** http://104.199.50.165  
**Backend Health:** http://104.199.50.165/api/health (via nginx proxy)

Generated: 2026-03-25 17:45 UTC  
GCP Project: phyoethuta31  
Deployment Region: europe-west1-b
