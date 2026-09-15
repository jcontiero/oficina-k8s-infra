variable "datadog_api_key" {
  description = "Datadog API Key"
  type        = string
  sensitive   = true
}

variable "datadog_site" {
  description = "Datadog site (e.g. datadoghq.com, us5.datadoghq.com)"
  type        = string
  default     = "datadoghq.com"
}
