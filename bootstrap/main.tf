terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.30.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. Habilitar APIs Essenciais
resource "google_project_service" "apis" {
  for_each = toset([
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",         # GKE
    "sqladmin.googleapis.com",          # Cloud SQL
    "vpcaccess.googleapis.com",         # Serverless VPC Access
    "servicenetworking.googleapis.com", # Private Services Access
    "secretmanager.googleapis.com",
    "iamcredentials.googleapis.com", # Workload Identity Federation
    "artifactregistry.googleapis.com",
    "cloudfunctions.googleapis.com",
    "run.googleapis.com", # Cloud Run (usado pelo Functions v2)
    "cloudbuild.googleapis.com",
    "pubsub.googleapis.com",
    "firestore.googleapis.com",
    "apigateway.googleapis.com",
    "servicecontrol.googleapis.com",
    "servicemanagement.googleapis.com",
    "storage.googleapis.com",
  ])
  service            = each.key
  disable_on_destroy = false
}

# 2. Criar Bucket de State
resource "google_storage_bucket" "tf_state" {
  name          = var.state_bucket_name
  location      = var.region
  force_destroy = false

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.apis]
}

# 3. Criar Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Pool para o GitHub Actions se autenticar via OIDC"
  disabled                  = false
  depends_on                = [google_project_service.apis]
}

# 4. Criar Workload Identity Provider
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  display_name                       = "GitHub Actions OIDC"
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.ref"              = "assertion.ref"
  }
  attribute_condition = "assertion.repository_owner == \"jcontiero\" && assertion.ref in [\"refs/heads/main\", \"refs/heads/homolog\"] && assertion.event_name in [\"workflow_dispatch\", \"push\"]"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# 5. Criar Service Account da Plataforma
resource "google_service_account" "platform_sa" {
  account_id   = "github-actions-sa"
  display_name = "GitHub Actions Platform SA"
}

# 6. Permissões granulares por domínio para a SA de CI/CD (sem roles/owner nem roles/editor)
resource "google_project_iam_member" "sa_roles" {
  for_each = toset([
    "roles/compute.networkAdmin",
    "roles/container.admin",
    "roles/cloudsql.admin",
    "roles/pubsub.admin",
    "roles/datastore.owner",
    "roles/secretmanager.admin",
    "roles/artifactregistry.admin",
    "roles/cloudfunctions.admin",
    "roles/run.admin",
    "roles/apigateway.admin",
    "roles/servicemanagement.admin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/resourcemanager.projectIamAdmin",
    "roles/storage.admin",
    "roles/logging.admin",
    "roles/monitoring.admin",
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.platform_sa.email}"
}

# 7. Conectar o Repositório do GitHub à Service Account
resource "google_service_account_iam_member" "github_sa_impersonation" {
  for_each = toset([
    "jcontiero/oficina-api",
    "jcontiero/oficina-billing",
    "jcontiero/oficina-execucao",
    "jcontiero/oficina-serverless",
    "jcontiero/oficina-k8s-infra",
    "jcontiero/oficina-database-infra"
  ])

  service_account_id = google_service_account.platform_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${each.key}"
}
