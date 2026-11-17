variable "project_id" {
  type    = string
  default = "fiap-project-514922"
}

variable "region" {
  type    = string
  default = "us-east1"
}

variable "cluster_name" {
  type    = string
  default = "oficina-gke-cluster"
}

variable "vpc_name" {
  type    = string
  default = "oficina-vpc"
}

variable "datadog_api_key" {
  description = "Datadog API Key"
  type        = string
  sensitive   = true
  default     = "a_preencher"
}

variable "datadog_site" {
  description = "Datadog site"
  type        = string
  default     = "us5.datadoghq.com"
}
