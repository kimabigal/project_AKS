variable "namespace" {
  description = "Namespace for applications"
  type        = string
  default     = "apps"
}

variable "acr_server" {
  description = "Azure Container Registry server name"
  type        = string
  default     = "myacr12067.azurecr.io"
}

variable "image_pull_secret" {
  description = "Kubernetes imagePullSecret name"
  type        = string
  default     = "acr-pull"
}

variable "web_image_tag" {
  description = "Tag for web image"
  type        = string
  default     = "v1"
}

variable "api_image_tag" {
  description = "Tag for api image"
  type        = string
  default     = "v1"
}

variable "mysql_root_password" {
  description = "Root password for MySQL"
  type        = string
  default     = "rootpass123"
}

variable "mysql_user" {
  description = "MySQL username"
  type        = string
  default     = "kaizen"
}

variable "mysql_password" {
  description = "MySQL password"
  type        = string
  default     = "Hello123!"
}

variable "mysql_db_name" {
  description = "Database name"
  type        = string
  default     = "hello"
}
