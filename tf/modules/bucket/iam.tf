# Cloud Run — full object access (always)
resource "google_storage_bucket_iam_member" "cloud_run_rw" {
  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.cloud_run_sa_email}"
}

resource "google_service_account_iam_member" "cloud_run_signer" {
  service_account_id = "projects/${var.project}/serviceAccounts/${var.cloud_run_sa_email}"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${var.cloud_run_sa_email}"
}

# Public read — only if enabled
resource "google_storage_bucket_iam_member" "public_read" {
  count  = var.bucket_public_access ? 1 : 0

  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
