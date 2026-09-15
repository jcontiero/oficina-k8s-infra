variable "datadog_api_key" {
  description = "Datadog API Key"
  type        = string
  sensitive   = true
}

variable "datadog_site" {
  description = "Datadog site"
  type        = string
  default     = "us5.datadoghq.com"
}

variable "cluster_name" {
  description = "Nome do cluster GKE"
  type        = string
  default     = "oficina-gke-cluster"
}
