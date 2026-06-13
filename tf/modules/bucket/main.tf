resource "google_storage_bucket" "bucket" {
  name     = var.bucket_name
  location = var.region

  force_destroy               = true
  uniform_bucket_level_access = true
  public_access_prevention    = "inherited"

  versioning {
    enabled = true
  }

  dynamic "cors" {
    for_each = length(var.cors_allowed_origins) > 0 ? [1] : []

    content {
      origin          = var.cors_allowed_origins
      method          = ["GET", "PUT", "POST", "HEAD"]
      response_header = ["Content-Type", "Authorization"]
      max_age_seconds = 3600
    }
  }
}
