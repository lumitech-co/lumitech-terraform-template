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

  instance_limit_cpus   = var.cloud_run_instance_limit_cpus
  instance_limit_memory = var.cloud_run_instance_limit_memory
  min_instance_count    = var.cloud_run_min_instance_count

  env_vars = {
    NODE_ENV        = "production"
    NEXT_PUBLIC_API_URL = var.next_public_api_url
  }

  depends_on = [
    module.project_api,
  ]
}
