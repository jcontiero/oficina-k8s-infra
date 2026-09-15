resource "google_compute_network" "main" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "${var.vpc_name}-gke-subnet"
  ip_cidr_range = "10.0.0.0/20"
  region        = var.region
  network       = google_compute_network.main.id

  secondary_ip_range {
    range_name    = "gke-pods-range"
    ip_cidr_range = "10.4.0.0/14"
  }
  secondary_ip_range {
    range_name    = "gke-services-range"
    ip_cidr_range = "10.0.32.0/20"
  }
}

# Subnet for Serverless VPC Access Connector (Req R-04)
# Needs to be /28
resource "google_compute_subnetwork" "serverless_subnet" {
  name          = "${var.vpc_name}-serverless-subnet"
  ip_cidr_range = "10.1.0.0/28"
  region        = var.region
  network       = google_compute_network.main.id
}

# Serverless VPC Access Connector
resource "google_vpc_access_connector" "connector" {
  name   = "oficina-connector"
  region = var.region
  subnet {
    name = google_compute_subnetwork.serverless_subnet.name
  }
  machine_type  = "e2-micro"
  min_instances = 2
  max_instances = 3
  depends_on    = [google_compute_subnetwork.serverless_subnet]
}

# Private Service Access for Cloud SQL
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "${var.vpc_name}-private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}

resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

