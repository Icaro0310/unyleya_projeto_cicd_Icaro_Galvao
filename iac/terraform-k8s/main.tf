# Terraform - Provisionamento de recursos Kubernetes
# Substituto do AKS: cluster kind (Kubernetes in Docker)
# Substituto do ACR: registry Docker local (porta 5000)

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
  }
}

# Provider Kubernetes - conexao com cluster kind
provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = "kind-unyleya-k8s"
}

# Variaveis
variable "kubeconfig_path" {
  description = "Caminho para o kubeconfig do cluster"
  type        = string
  default     = "~/.kube/config"
}

variable "namespace_name" {
  description = "Nome do namespace para a aplicacao"
  type        = string
  default     = "azure-vote"
}

variable "app_name" {
  description = "Nome da aplicacao"
  type        = string
  default     = "azure-vote-front"
}

variable "app_image" {
  description = "Imagem da aplicacao (registry local substituindo ACR)"
  type        = string
  default     = "localhost:5000/azure-vote-front:latest"
}

variable "redis_image" {
  description = "Imagem do Redis"
  type        = string
  default     = "mcr.microsoft.com/oss/bitnami/redis:6.0.8"
}

variable "app_replicas" {
  description = "Numero de replicas do frontend"
  type        = number
  default     = 2
}

# ============================
# Namespace
# ============================
resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = var.namespace_name
    labels = {
      app         = "azure-vote"
      managed-by  = "terraform"
      environment = "production"
    }
  }
}

# ============================
# ConfigMap - configuracao da aplicacao
# ============================
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "azure-vote-config"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  data = {
    TITLE       = "Azure Voting App - Unyleya"
    VOTE1VALUE  = "Cats"
    VOTE2VALUE  = "Dogs"
    SHOWHOST    = "false"
  }
}

# ============================
# Deployment - Frontend (Flask)
# ============================
resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
    labels = {
      app = var.app_name
      tier = "frontend"
    }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app  = var.app_name
          tier = "frontend"
        }
      }

      spec {
        container {
          name  = "azure-vote-front"
          image = var.app_image

          port {
            container_port = 80
            protocol       = "TCP"
          }

          env {
            name  = "REDIS"
            value = "azure-vote-back"
          }

          env {
            name  = "TITLE"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.app_config.metadata[0].name
                key  = "TITLE"
              }
            }
          }

          env {
            name  = "VOTE1VALUE"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.app_config.metadata[0].name
                key  = "VOTE1VALUE"
              }
            }
          }

          env {
            name  = "VOTE2VALUE"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.app_config.metadata[0].name
                key  = "VOTE2VALUE"
              }
            }
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
      }
    }
  }
}

# ============================
# Deployment - Backend (Redis)
# ============================
resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "azure-vote-back"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
    labels = {
      app  = "azure-vote-back"
      tier = "backend"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "azure-vote-back"
      }
    }

    template {
      metadata {
        labels = {
          app  = "azure-vote-back"
          tier = "backend"
        }
      }

      spec {
        container {
          name  = "azure-vote-back"
          image = var.redis_image

          port {
            container_port = 6379
            protocol       = "TCP"
          }

          env {
            name  = "ALLOW_EMPTY_PASSWORD"
            value = "yes"
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}

# ============================
# Service - Frontend (LoadBalancer)
# ============================
resource "kubernetes_service" "frontend" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
    labels = {
      app = var.app_name
    }
  }

  spec {
    type = "NodePort"

    port {
      port        = 80
      target_port = 80
      node_port   = 30080
      protocol    = "TCP"
    }

    selector = {
      app = var.app_name
    }
  }
}

# ============================
# Service - Backend (ClusterIP)
# ============================
resource "kubernetes_service" "backend" {
  metadata {
    name      = "azure-vote-back"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
    labels = {
      app = "azure-vote-back"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      port        = 6379
      target_port = 6379
      protocol    = "TCP"
    }

    selector = {
      app = "azure-vote-back"
    }
  }
}

# ============================
# Outputs
# ============================
output "namespace" {
  value = kubernetes_namespace.app_namespace.metadata[0].name
}

output "frontend_service_name" {
  value = kubernetes_service.frontend.metadata[0].name
}

output "frontend_node_port" {
  value = kubernetes_service.frontend.spec[0].port[0].node_port
}

output "backend_service_name" {
  value = kubernetes_service.backend.metadata[0].name
}