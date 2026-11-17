terraform {
  backend "gcs" {
    bucket = "fiap-project-514922-tfstate"
    prefix = "platform/network-gke"
  }
}
