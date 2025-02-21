resource "google_compute_network" "primary" {
  name                    = "${var.service_name}-vpc"
  auto_create_subnetworks = false
}

# Subnetwork
resource "google_compute_subnetwork" "primary" {
  name          = "${var.service_name}-subnet"
  ip_cidr_range = "10.2.0.0/24"
  region        = var.region
  network       = google_compute_network.primary.id
}

resource "google_compute_global_address" "postgres_private_ip" {
  name          = "${var.db_instance_name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.primary.id
}

resource "google_service_networking_connection" "postgres_private" {
  network                 = google_compute_network.primary.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.postgres_private_ip.name]
}

