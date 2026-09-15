module "vpc" {
  source   = "./modules/vpc"
  vpc_name = var.vpc_name
  region   = var.region
}

module "gke" {
  source       = "./modules/gke"
  project_id   = var.project_id
  region       = var.region
  cluster_name = var.cluster_name
  network_id   = module.vpc.network_id
  subnet_name  = module.vpc.subnet_name
  node_count   = 1
  machine_type = "e2-medium"
}

module "artifact_registry" {
  source        = "./modules/artifact_registry"
  region        = var.region
  repository_id = "oficina-docker"
}

module "datadog" {
  source          = "./modules/datadog"
  datadog_api_key = var.datadog_api_key

  depends_on = [module.gke]
}
