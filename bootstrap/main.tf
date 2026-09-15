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
    "iamcredentials.googleapis.com",    # Workload Identity Federation
    "artifactregistry.googleapis.com",
    "cloudfunctions.googleapis.com",
    "run.googleapis.com",               # Cloud Run (usado pelo Functions v2)
    "cloudbuild.googleapis.com"
  ])
  service = each.key
  disable_on_destroy = false
}

# 2. Criar Bucket de State
resource "google_storage_bucket" "tf_state" {
  name          = "${var.project_id}-tf-state"
  location      = var.region
  force_destroy = false

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
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
  }
  attribute_condition = "assertion.repository_owner == \"jcontiero\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# 5. Criar Service Account da Plataforma
resource "google_service_account" "platform_sa" {
  account_id   = "github-actions-sa"
  display_name = "GitHub Actions Platform SA"
}

# 6. Dar permissão de Editor (ou Owner) para a SA gerenciar o GCP
resource "google_project_iam_member" "sa_owner" {
  project = var.project_id
  role    = "roles/owner" # Para o Tech Challenge, Owner simplifica os pacotes subsequentes
  member  = "serviceAccount:${google_service_account.platform_sa.email}"
}

# 7. Conectar o Repositório do GitHub à Service Account
resource "google_service_account_iam_member" "github_sa_impersonation" {
  for_each = toset([
    "jcontiero/oficina-api",
    "jcontiero/oficina-serverless",
    "jcontiero/oficina-k8s-infra",
    "jcontiero/oficina-database-infra"
  ])

  service_account_id = google_service_account.platform_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${each.key}"
}
