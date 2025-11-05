terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33"
    }
  }
}


provider "kubernetes" {
  config_path = "~/.kube/config"
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}


resource "kubernetes_namespace" "apps" {
  metadata { name = "apps" }
}

resource "helm_release" "mysql" {
  name       = "mysql"
  namespace  = kubernetes_namespace.apps.metadata[0].name
  chart      = "${path.module}/../app-mysql/helm-sql"

  set { name = "auth.rootPassword" value = "rootpass123" }
  set { name = "auth.user"         value = "kaizen" }
  set { name = "auth.password"     value = "Hello123!" }
  set { name = "auth.database"     value = "hello" }
 
}

locals {
  acr_server = "myacr12067.azurecr.io"
}

resource "helm_release" "api" {
  name       = "api"
  namespace  = kubernetes_namespace.apps.metadata[0].name
  chart      = "${path.module}/../app-api/helm-api"
  depends_on = [helm_release.mysql]

 
  set { name = "deployment.image.repository"     value = "${local.acr_server}/api-app" }
  set { name = "deployment.image.tag"            value = "v1" }
  set { name = "deployment.imagePullSecretName"  value = "acr-pull" }

  
  set { name = "env.DB_HOST"   value = "mysql" }           
  set { name = "env.DB_NAME"   value = "hello" }
  set { name = "secrets.DB_USER" value = "kaizen" }
  set { name = "secrets.DB_PASS" value = "Hello123!" }
}


resource "helm_release" "web" {
  name       = "web"
  namespace  = kubernetes_namespace.apps.metadata[0].name
  chart      = "${path.module}/../app-web/helm-web"
  depends_on = [helm_release.api]

  set { name = "deployment.image.repository"     value = "${local.acr_server}/web-app" }
  set { name = "deployment.image.tag"            value = "v1" }
  set { name = "deployment.imagePullSecretName"  value = "acr-pull" }


  set { name = "env.API_HOST" value = "http://api.apps.svc.cluster.local:3000" }
}
