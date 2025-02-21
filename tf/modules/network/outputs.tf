output "network_id" {
  value = google_compute_network.primary.id
}

output "subnetwork_id" {
  value = google_compute_subnetwork.primary.id
}

output "network_self_link" {
  value = google_compute_network.primary.self_link
}


