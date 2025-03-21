terraform {
  required_version = ">= 1.10.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.20.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_storage_bucket" "tfstate" {
  name     = "${var.environment}-${var.project}-tfstate"
  location = var.region

  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 5
    }

    action {
      type = "Delete"
    }
  }
}

resource "local_file" "backend" {
  file_permission = "0644"
  filename        = "${path.module}/backend.tf"

  content = <<-EOT
  terraform {
    backend "gcs" {
      bucket = "${google_storage_bucket.tfstate.name}"
    }
  }
  EOT
}

module "project_api" {
  source = "../modules/project-api"
}

module "network" {
  source = "../modules/network"

  service_name     = var.service_name
  region           = var.region
  db_instance_name = var.db_instance_name

  depends_on = [module.project_api]
}

module "secret" {
  source = "../modules/secret"

  environment = var.environment
}

module "cloud_run" {
  source = "../modules/cloud-run"

  set_dummy_image = var.cloud_run_set_dummy_image

  project = var.project
  region  = var.region

  environment = var.environment

  gh_owner       = var.gh_owner
  gh_repo_name   = var.gh_repo_name
  service_name   = var.service_name
  gh_branch_name = var.gh_branch_name

  db_connection_name = module.cloud_sql.cloud_sql_instance_name

  instance_limit_cpus   = var.cloud_run_instance_limit_cpus
  instance_limit_memory = var.cloud_run_instance_limit_memory
  min_instance_count    = var.cloud_run_min_instance_count

  subnetwork_id = module.network.subnetwork_id
  network_id    = module.network.network_id

  env_vars = {
    NODE_ENV        = "production"
    APPLICATION_URL = var.cloud_run_application_url
    DOCS_PASSWORD   = "password"
  }

  secret_vars = {
    DATABASE_URL       = module.cloud_sql.database_url_secret_id
    APPLICATION_SECRET = module.secret.application_secret
    // EXAMPLE_SECRET_FOR_CLOUD_RUN = var.example_secret_for_cloud_run
  }

  depends_on = [
    module.cloud_sql,
    module.network,
    module.project_api,
    module.secret,
  ]
}

module "cloud_sql" {
  source = "../modules/cloud-sql"

  project                = var.project
  region                 = var.region
  db_instance_name       = var.db_instance_name
  db_deletion_protection = var.cloud_sql_db_deletion_protection

  gh_owner       = var.gh_owner
  gh_repo_name   = var.gh_repo_name
  gh_branch_name = var.gh_branch_name
  environment    = var.environment

  db_tier = var.cloud_sql_tier

  network_self_link = module.network.network_self_link

  depends_on = [
    module.network,
    module.project_api,
    module.secret,
  ]
}

