resource "google_sql_database_instance" "postgres" {
  name             = var.db_instance_name
  database_version = "POSTGRES_16"
  region           = var.region

  deletion_protection = var.db_deletion_protection

  settings {
    tier      = var.db_tier
    disk_size = 10

    edition                     = "ENTERPRISE"
    deletion_protection_enabled = var.db_deletion_protection

    ip_configuration {
      ipv4_enabled    = true
      private_network = var.network_self_link

      authorized_networks {
        name  = "all"
        value = "0.0.0.0/0"
      }
    }
  }
}

resource "random_password" "db_postgres_password" {
  length  = 17
  special = false
}

resource "google_sql_user" "users" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres.name
  password = random_password.db_postgres_password.result

  type = "BUILT_IN"

  deletion_policy = "ABANDON"
}
