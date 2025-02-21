resource "google_secret_manager_secret" "database_url" {
  project   = var.project
  secret_id = "${var.db_instance_name}-database_url"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "database_url" {
  secret = google_secret_manager_secret.database_url.id
  secret_data = format("postgresql://postgres:%s@localhost/%s?host=/cloudsql/%s",
    random_password.db_postgres_password.result,
    "postgres",
    google_sql_database_instance.postgres.connection_name
  )
}
