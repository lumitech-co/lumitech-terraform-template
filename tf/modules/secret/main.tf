resource "random_password" "app_secret" {
  length  = 40
  special = true
}

resource "google_secret_manager_secret" "application_secret" {
  secret_id = "${var.environment}-application-secret"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "application_secret" {
  secret      = google_secret_manager_secret.application_secret.id
  secret_data = random_password.app_secret.result
}

output "application_secret" {
  value = google_secret_manager_secret.application_secret.secret_id
}
