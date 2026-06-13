output "bucket_name" {
  description = "The private bucket name"
  value       = google_storage_bucket.bucket.name
}
