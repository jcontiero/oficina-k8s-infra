output "network_name" {
  value = google_compute_network.main.name
}
output "network_id" {
  value = google_compute_network.main.id
}
output "subnet_name" {
  value = google_compute_subnetwork.gke_subnet.name
}
output "connector_name" {
  value = google_vpc_access_connector.connector.name
}
output "private_vpc_connection" {
  value = google_service_networking_connection.default.network
}
