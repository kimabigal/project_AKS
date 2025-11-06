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

# Namespace
resource "kubernetes_namespace" "apps" {
  metadata {
    name = var.namespace
  }
}

# MySQL
resource "helm_release" "mysql" {
  name      = "mysql"
  namespace = kubernetes_namespace.apps.metadata[0].name
  chart     = abspath("${path.module}/../../app-mysql/helm-sql")

  set {
    name  = "mysql.rootPassword"
    value = var.mysql_root_password
  }
  set {
    name  = "mysql.user"
    value = var.mysql_user
  }
  set {
    name  = "mysql.password"
    value = var.mysql_password
  }
  set {
    name  = "mysql.dbName"
    value = var.mysql_db_name
  }
  set {
    name  = "mysql.storage"
    value = "10Gi"
  }

  timeout = 300
}

# API
resource "helm_release" "api" {
  name       = "api"
  namespace  = kubernetes_namespace.apps.metadata[0].name
  chart      = abspath("${path.module}/../../app-api/helm-api")
  depends_on = [helm_release.mysql]

  # image
  set {
    name  = "deployment.image.repository"
    value = "${var.acr_server}/api-app"
  }
  set {
    name  = "deployment.image.tag"
    value = var.api_image_tag
  }
  set {
    name  = "deployment.imagePullSecretName"
    value = var.image_pull_secret 
  }

  
  set {
    name  = "deployment.port"
    value = "3000"
  }
  set {
    name  = "service.port"
    value = "3000"
  }
  set {
    name  = "service.targetPort"
    value = "3000"
  }
  set {
    name  = "env.PORT"
    value = "3000"
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "env.DB_HOST"
    value = "mysql"
  }
  set {
    name  = "env.DB_NAME"
    value = var.mysql_db_name
  }
  set {
    name  = "secrets.DB_HOST"
    value = "mysql"
  }
  set {
    name  = "secrets.DB_NAME"
    value = var.mysql_db_name
  }
  set {
    name  = "secrets.DB_USER"
    value = var.mysql_user
  }
  set {
    name  = "secrets.DB_PASS"
    value = var.mysql_password
  }

  timeout = 300
}

# WEB
resource "helm_release" "web" {
  name       = "web"
  namespace  = kubernetes_namespace.apps.metadata[0].name
  chart      = abspath("${path.module}/../../app-web/helm-web")
  depends_on = [helm_release.api]

  # image
  set {
    name  = "deployment.image.repository"
    value = "${var.acr_server}/web-app"
  }
  set {
    name  = "deployment.image.tag"
    value = var.web_image_tag
  }
  set {
    name  = "deployment.imagePullSecretName"
    value = var.image_pull_secret # if AKS is not attached to ACR
  }

 
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }


  set {
    name  = "env.API_HOST"
    value = "http://api-service:3000"
  }

  timeout = 300
}
