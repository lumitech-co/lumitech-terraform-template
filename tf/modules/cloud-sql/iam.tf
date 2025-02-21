resource "google_service_account" "cloudbuild_migration" {
  account_id   = "${var.environment}-cloudbuild-migration"
  display_name = "Service Account for DB Migrations using Cloud Build (${var.environment})"
}

resource "google_secret_manager_secret_iam_member" "database_url_secret_access" {
  secret_id = google_secret_manager_secret.database_url.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloudbuild_migration.email}"
}

resource "google_project_iam_member" "sql_access" {
  member  = "serviceAccount:${google_service_account.cloudbuild_migration.email}"
  project = var.project
  role    = "roles/cloudsql.client"
}

resource "google_project_iam_member" "act_as" {
  project = var.project
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloudbuild_migration.email}"
}

resource "google_project_iam_member" "migration_source" {
  project = var.project
  role    = "roles/source.reader"
  member  = "serviceAccount:${google_service_account.cloudbuild_migration.email}"
}

resource "google_project_iam_member" "migration_logging" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudbuild_migration.email}"
}

