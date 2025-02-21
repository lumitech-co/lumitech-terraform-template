variable "project" {
  type        = string
  description = "The GCP project ID to deploy resources"
}

variable "region" {
  type        = string
  description = "Region where to deploy resources"
}

variable "db_instance_name" {
  description = "DB instance name"
  type        = string
}

variable "network_self_link" {
  description = "VPC Network Self Link"
  type        = string
}

variable "db_deletion_protection" {
  description = "DB deletion protection"
  type        = bool
  default     = true
}

variable "db_tier" {
  description = "DB tier"
  type        = string
}

variable "environment" {
  type        = string
  description = "Environment name"
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

