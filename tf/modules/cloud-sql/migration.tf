resource "google_cloudbuild_trigger" "run_migration" {
  description = "Migration Repository Trigger ${var.gh_repo_name} (${var.gh_branch_name}) ${var.environment}"

  github {
    push {
      branch = var.gh_branch_name
    }
    name  = var.gh_repo_name
    owner = var.gh_owner
  }

  substitutions = {
    _CLOUD_SQL_INSTANCE     = google_sql_database_instance.postgres.connection_name
    _DATABASE_URL_SECRET_ID = google_secret_manager_secret.database_url.name
  }

  filename = "migration-cloudbuild.yaml"

  service_account = google_service_account.cloudbuild_migration.id
}
