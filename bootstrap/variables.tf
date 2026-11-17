variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "fiap-project-514922"
}

variable "region" {
  description = "GCP Region para os recursos base"
  type        = string
  default     = "us-east1"
}

variable "state_bucket_name" {
  description = "Nome do bucket GCS para o backend Terraform da P7"
  type        = string
  default     = "fiap-project-514922-tfstate"
}
