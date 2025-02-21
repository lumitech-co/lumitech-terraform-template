variable "project" {
  type        = string
  description = "The GCP project ID to deploy resources"
}

variable "region" {
  type        = string
  description = "Region where to deploy resources"
}

variable "environment" {
  type        = string
  description = "Resources deployment environment"

}

variable "service_name" {
  description = "Deployed resources naming"
  type        = string
}

variable "gh_branch_name" {
  description = "The branch name to trigger new revisions from"
  default     = "main"
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

variable "network_id" {
  description = "Computer Network Id"
  type        = string
}

variable "subnetwork_id" {
  description = "VPC Subnetwork Id"
  type        = string
}

variable "db_connection_name" {
  description = "Postgres DB Connection Name"
  type        = string
}

variable "set_dummy_image" {
  description = "Set dummy image for Cloud Run (use when Artifact Registry is not yet created and has no image)"
  type        = bool
}

variable "secret_vars" {
  description = "A map of secret environment variables to pass to the container."
  type        = map(string)
  default     = {}
}

variable "env_vars" {
  description = "A map of environment variables to pass to the container."
  type        = map(string)
  default     = {}
}

variable "min_instance_count" {
  description = "Minimum number of instances to run"
  type        = number
  default     = 0
}

variable "instance_limit_cpus" {
  description = "Number of CPUs for the instance"
  type        = number
}

variable "instance_limit_memory" {
  description = "Memory for the instance: 512Mi, 1024Mi, 2Gi, 4Gi, 8Gi, 16Gi etc."
  type        = string
}
