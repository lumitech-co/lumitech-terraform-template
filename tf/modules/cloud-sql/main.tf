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

    backup_configuration {
      enabled                        = true
      start_time                     = "00:00" # UTC
      location                       = var.region
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
    }

    ip_configuration {
      ipv4_enabled    = true
      private_network = var.network_self_link

      dynamic "authorized_networks" {
        for_each = var.allowed_ips

        content {
          name  = "allowed-${replace(authorized_networks.value, "/", "-")}"
          value = authorized_networks.value
        }
      }
    }

    dynamic "database_flags" {
      for_each = var.database_flags

      content {
        name  = database_flags.value.name
        value = database_flags.value.value
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
