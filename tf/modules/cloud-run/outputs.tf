output "api_url" {
  value = google_cloud_run_v2_service.node-api.uri
}

output "cloud_run_sa_email" {
  value = google_service_account.cloud_run_sa.email
}

output "deploy_trigger_id" {
  value = google_cloudbuild_trigger.run_deploy.trigger_id
}
