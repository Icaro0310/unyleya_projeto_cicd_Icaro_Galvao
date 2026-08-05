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

variable "app_image" {
  description = "Imagem da aplicacao (registry local substituindo ACR)"
  type        = string
  default     = "localhost:5000/azure-vote-front:latest"
}