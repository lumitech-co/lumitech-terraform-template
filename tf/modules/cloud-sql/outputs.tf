output "cloud_sql_instance_name" {
  value = google_sql_database_instance.postgres.connection_name
}

output "database_url_secret_id" {
  value = google_secret_manager_secret.database_url.id
}
