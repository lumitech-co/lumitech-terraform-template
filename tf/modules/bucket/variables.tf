variable "project" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Name of the bucket"
  type        = string
}

variable "bucket_public_access" {
  description = "Whether the GCS bucket should allow public access (true = public, false = private)"
  type        = bool
}

variable "cloud_run_sa_email" {
  description = "Email of the Cloud Run service account that will access resources (e.g., bucket, Pub/Sub)"
  type        = string
}

variable "cors_allowed_origins" {
  description = "List of allowed origins for browser uploads (CORS)"
  type        = list(string)
}
