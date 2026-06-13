resource "google_monitoring_notification_channel" "email" {
  for_each = toset(var.alert_emails)

  project      = var.project
  display_name = "Email Alert - ${each.value}"
  type         = "email"

  # Allow deletion even while an alert policy still references the channel, so removing
  # an email from var.alert_emails doesn't fail with a "still being referenced" error.
  force_delete = true

  labels = {
    email_address = each.value
  }
}

# Do NOT set `project` here: slack_auth_token_secret_id is a full path
# (projects/<number>/secrets/...). Setting project to the project ID conflicts with the
# project number in the path. Omitting it lets the provider derive project from the path.
data "google_secret_manager_secret_version" "slack_auth_token" {
  count  = var.slack_channel_name != "" ? 1 : 0
  secret = var.slack_auth_token_secret_id
}

resource "google_monitoring_notification_channel" "slack" {
  count = var.slack_channel_name != "" ? 1 : 0

  project      = var.project
  display_name = "Slack Alert - ${var.slack_channel_name}"
  type         = "slack"

  # Allow deletion even while an alert policy still references the channel, so disabling
  # Slack (clearing var.slack_channel_name) doesn't fail with a "still being referenced" error.
  force_delete = true

  labels = {
    channel_name = var.slack_channel_name
  }

  sensitive_labels {
    auth_token = data.google_secret_manager_secret_version.slack_auth_token[0].secret_data
  }
}

locals {
  logs_query = <<-EOT
    resource.type="cloud_run_revision"
    resource.labels.service_name="${var.service_name}"
    severity>=ERROR
  EOT

  logs_explorer_url = "https://console.cloud.google.com/logs/query;query=${urlencode(trimspace(local.logs_query))}?project=${var.project}"
}

resource "google_monitoring_alert_policy" "cloud_run_5xx" {
  project      = var.project
  display_name = "${var.service_name} - Cloud Run 5xx errors"
  combiner     = "OR"

  documentation {
    mime_type = "text/markdown"
    subject   = "Cloud Run 5xx errors on ${var.service_name}"
    content   = "Cloud Run service *${var.service_name}* is returning 5xx errors.\n\n[View error logs in Logs Explorer](${local.logs_explorer_url})"

    links {
      display_name = "Error logs"
      url          = local.logs_explorer_url
    }
  }

  conditions {
    display_name = "5xx response count > 0"

    condition_threshold {
      filter = <<-EOT
        resource.type = "cloud_run_revision"
        AND resource.labels.service_name = "${var.service_name}"
        AND metric.type = "run.googleapis.com/request_count"
        AND metric.labels.response_code_class = "5xx"
      EOT

      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = concat(
    [for c in google_monitoring_notification_channel.email : c.id],
    google_monitoring_notification_channel.slack[*].id,
  )

  alert_strategy {
    auto_close = "1800s"

    # Notify only when an incident opens, not when it auto-resolves.
    notification_prompts = ["OPENED"]
  }
}
