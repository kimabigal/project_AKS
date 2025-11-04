# project_AKS
```bash
1. Clone the repo
git clone https://github.com/kimabigal/project_AKS.git
cd project_AKS

2. Create AKS cluster via Terraform
cd cluster
terraform init -upgrade
terraform validate
terraform apply -auto-approve


Outputs include the resource group and AKS cluster name.

3. Connect kubectl to AKS
RG="my-aks-rg-westus2"
AKS="my-mini-aks"

az aks get-credentials -g "$RG" -n "$AKS" --overwrite-existing
kubectl get nodes

4. Build & Push Docker Images
ACR_NAME="myacr12067"
ACR_SERVER=$(az acr show -n "$ACR_NAME" --query loginServer -o tsv)

# Web
docker build -t "$ACR_SERVER/web-app:v1" -f app-web/web/Dockerfile app-web/web
# API
docker build -t "$ACR_SERVER/api-app:v1" -f app-api/api/Dockerfile app-api/api

# Push
az acr login -n "$ACR_NAME"
docker push "$ACR_SERVER/web-app:v1"
docker push "$ACR_SERVER/api-app:v1"

5. Create Namespaces & Image Pull Secrets
kubectl create ns web  --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns api  --dry-run=client -o yaml | kubectl apply -f -

az acr update -n "$ACR_NAME" --admin-enabled true
ACR_USER=$(az acr credential show -n "$ACR_NAME" --query username -o tsv)
ACR_PASS=$(az acr credential show -n "$ACR_NAME" --query passwords[0].value -o tsv)

kubectl -n web create secret docker-registry acr-pull \
  --docker-server="$ACR_SERVER" --docker-username="$ACR_USER" --docker-password="$ACR_PASS" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n api create secret docker-registry acr-pull \
  --docker-server="$ACR_SERVER" --docker-username="$ACR_USER" --docker-password="$ACR_PASS" \
  --dry-run=client -o yaml | kubectl apply -f -

6. Deploy Helm Charts
helm upgrade --install web app-web/helm-web -n web \
  --set deployment.image.repository="$ACR_SERVER/web-app" \
  --set deployment.image.tag="v1" \
  --set deployment.imagePullSecretName="acr-pull"

helm upgrade --install api app-api/helm-api -n api \
  --set deployment.image.repository="$ACR_SERVER/api-app" \
  --set deployment.image.tag="v1" \
  --set deployment.imagePullSecretName="acr-pull"

7. Verify Deployment
kubectl -n web get deploy,po,svc
kubectl -n api get deploy,po,svc
watch -n 3 'kubectl -n web get svc; kubectl -n api get svc'


When EXTERNAL-IP appears for each service:

curl http://<WEB-EXTERNAL-IP>
curl http://<API-EXTERNAL-IP>/health



DESTROY
cd cluster
terraform destroy -auto-approve

📁 Repository Structure
project_AKS/
├── app-api/
│   ├── api/                # API Node.js app
│   └── helm-api/           # Helm chart for API
├── app-web/
│   ├── web/                # Web Node.js app
│   └── helm-web/           # Helm chart for Web
└── cluster/                # Terraform infrastructure 