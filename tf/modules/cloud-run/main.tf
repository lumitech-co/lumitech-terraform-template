resource "google_cloud_run_v2_service" "node-api" {
  name                = var.service_name
  location            = var.region
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"

  template {
    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"

    containers {
      image = var.set_dummy_image ? "us-docker.pkg.dev/cloudrun/container/hello" : format("%s-docker.pkg.dev/%s/%s/%s:latest",
        google_artifact_registry_repository.artifact_repo.location,
        var.project,
        var.service_name,
        var.service_name
      )

      resources {
        limits = {
          cpu    = var.instance_limit_cpus
          memory = var.instance_limit_memory
        }
        cpu_idle          = false
        startup_cpu_boost = true
      }

      name = var.service_name

      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = var.secret_vars
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = env.value
              version = "latest"
            }
          }
        }
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }

    vpc_access {
      egress = "PRIVATE_RANGES_ONLY"

      network_interfaces {
        network    = var.network_id
        subnetwork = var.subnetwork_id
      }
    }

    scaling {
      min_instance_count = var.min_instance_count
      max_instance_count = 1
    }

    service_account = google_service_account.cloud_run_sa.email

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [var.db_connection_name]
      }
    }
  }

  lifecycle {
    ignore_changes = [
      client,
      client_version
    ]
  }

  depends_on = [
    google_artifact_registry_repository.artifact_repo,
  ]
}

resource "google_cloudbuild_trigger" "run_deploy" {
  description = "Deployment Repository Trigger ${var.gh_repo_name} (${var.gh_branch_name}) ${var.environment}"

  github {
    push {
      branch = var.gh_branch_name
    }
    name  = var.gh_repo_name
    owner = var.gh_owner
  }

  substitutions = {
    _AR_DOCKER_IMAGE_URI = format(
      "%s-docker.pkg.dev/%s/%s/%s",
      google_artifact_registry_repository.artifact_repo.location,
      var.project,
      var.service_name,
      var.service_name
    )
    _DEPLOY_REGION = var.region
    _SERVICE_NAME  = google_cloud_run_v2_service.node-api.name
  }

  filename = "cloudbuild.yaml"

  service_account = google_service_account.cloud_build.id

  depends_on = [google_artifact_registry_repository.artifact_repo]
}

resource "google_artifact_registry_repository" "artifact_repo" {
  repository_id = var.service_name
  format        = "DOCKER"
  location      = var.region
  description   = "Artifact Registry for Cloud Run deployment (${var.environment})"

  cleanup_policies {
    id     = "delete-old-images"
    action = "DELETE"
    condition {
      older_than = "7d"
    }
  }

  cleanup_policies {
    id     = "keep-recent-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count = 5
    }
  }
}
