resource "google_project_service" "cloud_scheduler" {
  project            = var.project
  service            = "cloudscheduler.googleapis.com"
  disable_on_destroy = false
}

resource "google_cloud_scheduler_job" "cron" {
  name        = var.name
  description = var.description
  schedule    = var.schedule
  time_zone   = var.time_zone

  http_target {
    http_method = var.http_method
    uri         = var.uri

    headers = merge(
      {
        "User-Agent"   = "Google-Cloud-Scheduler"
      },
      var.headers
    )

    body    = var.body != null ? base64encode(var.body) : null
  }

  depends_on = [
    google_project_service.cloud_scheduler
  ]
}
