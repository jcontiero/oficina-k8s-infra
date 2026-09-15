output "vpc_network_name" {
  value       = module.vpc.network_name
  description = "Nome da VPC para ser consumida pelo modulo de banco e serverless"
}

output "serverless_connector_name" {
  value       = module.vpc.connector_name
  description = "Nome do Serverless VPC Access connector para as Cloud Functions (R-04)"
}

output "gke_cluster_name" {
  value       = module.gke.cluster_name
  description = "Nome do cluster GKE"
}

output "gke_cluster_endpoint" {
  value       = module.gke.cluster_endpoint
  sensitive   = true
  description = "Endpoint do cluster GKE"
}

output "artifact_registry_repo" {
  value       = module.artifact_registry.repository_id
  description = "Repositorio Docker no Artifact Registry"
}
