variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region para os recursos base"
  type        = string
  default     = "us-central1"
}
