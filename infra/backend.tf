terraform {
  backend "gcs" {
    bucket = "pos-fiap-2026-tf-state"
    prefix = "env/shared/k8s-infra"
  }
}
