@echo off
REM 🚀 Signature App - Complete GCP Deployment Script (Windows)
REM This script automates the entire deployment process to GCP

setlocal enabledelayedexpansion

REM Colors (Windows CMD doesn't support colors easily, so we'll just use text)
echo.
echo ========================================
echo 🚀 Signature App - GCP Deployment
echo ========================================
echo.

REM Check if PROJECT_ID is set
if "%GCP_PROJECT_ID%"=="" (
    echo Enter your GCP Project ID:
    set /p PROJECT_ID=
) else (
    set PROJECT_ID=%GCP_PROJECT_ID%
)

if "%PROJECT_ID%"=="" (
    echo Error: Project ID is required
    exit /b 1
)

echo Project ID: %PROJECT_ID%
echo.

REM Set configuration
set REGION=us-central1
set CLUSTER_NAME=signature-app-cluster
set DOCKER_REGISTRY=gcr.io

echo [Step 1/8] Checking prerequisites...
where gcloud >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: gcloud CLI not found. Install from: https://cloud.google.com/sdk/docs/install
    exit /b 1
)
echo ✓ gcloud found

where kubectl >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: kubectl not found. Install from: https://kubernetes.io/docs/tasks/tools/
    exit /b 1
)
echo ✓ kubectl found

where docker >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: docker not found. Install from: https://docs.docker.com/get-docker/
    exit /b 1
)
echo ✓ docker found
echo.

echo [Step 2/8] Setting up GCP Project...
gcloud config set project %PROJECT_ID%
echo ✓ Project set to: %PROJECT_ID%
echo.

echo [Step 3/8] Enabling required GCP APIs...
gcloud services enable ^
  container.googleapis.com ^
  containerregistry.googleapis.com ^
  cloudbuild.googleapis.com ^
  compute.googleapis.com ^
  servicenetworking.googleapis.com
echo ✓ APIs enabled
echo.

echo [Step 4/8] Building Docker images...
echo Building backend image...
docker build -t signature-backend:latest .\backend
docker tag signature-backend:latest %DOCKER_REGISTRY%/%PROJECT_ID%/signature-backend:latest

echo Building frontend image...
docker build -t signature-frontend:latest .\frontend
docker tag signature-frontend:latest %DOCKER_REGISTRY%/%PROJECT_ID%/signature-frontend:latest
echo ✓ Docker images built
echo.

echo [Step 5/8] Configuring Docker authentication...
gcloud auth configure-docker
echo ✓ Docker authenticated with GCP
echo.

echo [Step 6/8] Pushing images to Google Container Registry...
echo Pushing backend image...
docker push %DOCKER_REGISTRY%/%PROJECT_ID%/signature-backend:latest

echo Pushing frontend image...
docker push %DOCKER_REGISTRY%/%PROJECT_ID%/signature-frontend:latest
echo ✓ Images pushed to GCR
echo.

echo [Step 7/8] Creating/checking GKE cluster...
gcloud container clusters describe %CLUSTER_NAME% --region %REGION% >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Cluster already exists. Using existing cluster.
) else (
    echo Creating new cluster (this may take 5-10 minutes)...
    gcloud container clusters create %CLUSTER_NAME% ^
      --region %REGION% ^
      --num-nodes 3 ^
      --machine-type n1-standard-1 ^
      --enable-autoscaling ^
      --min-nodes 1 ^
      --max-nodes 5 ^
      --enable-autorepair ^
      --enable-autoupgrade
)

gcloud container clusters get-credentials %CLUSTER_NAME% --region %REGION%
echo ✓ GKE cluster ready
echo.

echo [Step 8/8] Deploying to Kubernetes...
echo Creating namespace and configuration...
kubectl apply -f k8s\namespace-config.yaml

echo Deploying MySQL database...
kubectl apply -f k8s\mysql.yaml

echo Waiting for MySQL to be ready (this may take 1-2 minutes)...
timeout /t 10
echo.

echo Deploying backend...
kubectl apply -f k8s\backend.yaml

echo Deploying frontend...
kubectl apply -f k8s\frontend.yaml

echo ✓ Deployment complete
echo.

echo Verifying deployment...
echo Waiting for pods to start (this may take 1-2 minutes)...
timeout /t 15

echo.
echo ========================================
echo 🎉 DEPLOYMENT SUCCESSFUL!
echo ========================================
echo.

echo Getting external IP (this may take a minute)...
:wait_for_ip
for /f %%i in ('kubectl get svc frontend-service -n signature-app -o jsonpath="{.status.loadBalancer.ingress[0].ip}" 2^>nul') do set EXTERNAL_IP=%%i

if "%EXTERNAL_IP%"=="" (
    echo Waiting for LoadBalancer IP...
    timeout /t 5 /nobreak
    goto wait_for_ip
)

echo.
echo ✓ Your application is now running!
echo.
echo Access your app at:
echo http://%EXTERNAL_IP%
echo.
echo Useful commands:
echo   View pods:     kubectl get pods -n signature-app
echo   View services: kubectl get svc -n signature-app
echo   View logs:     kubectl logs -f deployment/backend -n signature-app
echo   Scale backend: kubectl scale deployment backend --replicas=5 -n signature-app
echo.
echo Next steps:
echo 1. Open browser: http://%EXTERNAL_IP%
echo 2. Register a user
echo 3. Create and sign a form
echo.

endlocal
