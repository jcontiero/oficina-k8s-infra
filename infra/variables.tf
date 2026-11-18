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
  description = "Datadog API Key (restrita ao Agent)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "datadog_site" {
  description = "Datadog site"
  type        = string
  default     = "datadoghq.com"
}

variable "datadog_enabled" {
  description = "Instala o Agent; exige chave válida em datadog_api_key"
  type        = bool
  default     = true
}
