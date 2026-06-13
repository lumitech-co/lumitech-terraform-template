output "notification_channel_ids" {
  description = "IDs of all notification channels (email + Slack)"
  value = concat(
    [for c in google_monitoring_notification_channel.email : c.id],
    google_monitoring_notification_channel.slack[*].id,
  )
}

output "alert_policy_id" {
  description = "ID of the Cloud Run 5xx alert policy"
  value       = google_monitoring_alert_policy.cloud_run_5xx.id
}
