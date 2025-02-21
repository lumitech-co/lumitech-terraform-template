variable "project" {
  type        = string
  description = "The GCP project ID to deploy resources"
}

variable "region" {
  type        = string
  description = "Region where to deploy resources"
}

variable "zone" {
  description = "Region zone where to deploy resources"
  type        = string
}

variable "environment" {
  description = "The environment to deploy resources (dev, prod, staging, test)"
  type        = string
}

variable "service_name" {
  description = "Deployed resources naming e.g. my-project-name"
  type        = string
}

variable "gh_branch_name" {
  description = "The branch name to trigger new revisions from"
  type        = string
}

variable "gh_owner" {
  description = "The GitHub owner of the repository"
  type        = string
}

variable "gh_repo_name" {
  description = "The GitHub repository name"
  type        = string
}

variable "db_instance_name" {
  description = "The name of the Cloud SQL instance"
  type        = string
}

// cloud-run module

variable "cloud_run_instance_limit_cpus" {
  description = "The number of CPUs to allocate to the Cloud Run instance"
  type        = number
}

variable "cloud_run_instance_limit_memory" {
  description = "The amount of memory to allocate to the Cloud Run instance"
  type        = string
}

variable "cloud_run_min_instance_count" {
  description = "The minimum number of instances to run. Development - 0, production - 1. If there are 0 instances, the application will go to sleep to reduce costs."
  type        = number
}

variable "cloud_run_application_url" {
  description = "Cloud Run application URL"
  type        = string
}

variable "cloud_run_set_dummy_image" {
  description = "Option whether to use a Dockerfile image or a mock image from GCP. Change to true when initially creating cloud run resource (in order to avoid an error)."
  type        = bool
}

// cloud-sql module

variable "cloud_sql_tier" {
  description = "The tier of the Cloud SQL instance"
  type        = string
}

variable "cloud_sql_db_deletion_protection" {
  description = "Whether to enable deletion protection for the Cloud SQL instance"
  type        = bool
}

