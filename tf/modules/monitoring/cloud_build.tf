locals {
  build_history_url = "https://console.cloud.google.com/cloud-build/builds?project=${var.project}"

  # Link to the EXACT failed build's logs. $${log.extracted_label.build_id} is substituted by
  # Cloud Monitoring at notification time (escaped as $$ so Terraform emits the literal ${...});
  # build_id is pulled from the triggering log entry via the label_extractors blocks below.
  build_log_url = "https://console.cloud.google.com/cloud-build/builds;region=global/$${log.extracted_label.build_id}?project=${var.project}"

  # Drive alerts off what's actually provided: notify whatever channels are set
  # (email and/or Slack); if NEITHER is configured, create no build-failure alert.
  has_notification_channel = length(var.alert_emails) > 0 || var.slack_channel_name != ""

  # App ERROR-log filter. Pino (the backend logger) writes JSON to stdout with a numeric
  # `jsonPayload.level` (50 = error, 60 = fatal); Cloud Run maps stdout to INFO, NOT ERROR,
  # so matching severity>=ERROR alone misses app errors. We also match jsonPayload.level>=50.
  error_logs_query = <<-EOT
    resource.type="cloud_run_revision"
    resource.labels.service_name="${var.service_name}"
    (severity>=ERROR OR jsonPayload.level>=50)
  EOT

  # urlencode() encodes spaces as "+", but the Logs Explorer ;query= segment does NOT decode
  # "+" back to a space, so "ERROR OR jsonPayload" would arrive as "ERROR+OR+jsonPayload" and
  # be rejected as an invalid filter. Replace "+" with %20 so the spaces around OR survive.
  error_logs_explorer_url = "https://console.cloud.google.com/logs/query;query=${replace(urlencode(trimspace(local.error_logs_query)), "+", "%20")}?project=${var.project}"
}

resource "google_monitoring_alert_policy" "deploy_failed" {
  count = var.enable_deploy_alert && local.has_notification_channel ? 1 : 0

  project      = var.project
  display_name = "Deploy failed: ${var.service_name}"
  combiner     = "OR"

  documentation {
    mime_type = "text/markdown"
    subject   = "Cloud Build deploy failed for ${var.service_name}"
    content   = "A Cloud Run *deploy* build for *${var.service_name}* failed.\n\n[View build logs](${local.build_log_url})"

    links {
      display_name = "Cloud Build history"
      url          = local.build_history_url
    }
  }

  conditions {
    display_name = "Deploy build failed"

    condition_matched_log {
      # build_trigger_id scopes the match to THIS service+env's deploy trigger only.
      filter = <<-EOT
        resource.type="build"
        resource.labels.build_trigger_id="${var.deploy_trigger_id}"
        severity=ERROR
      EOT

      # Expose the failed build's id so the notification can link to the exact build.
      label_extractors = {
        "build_id" = "EXTRACT(resource.labels.build_id)"
      }
    }
  }

  notification_channels = concat(
    [for c in google_monitoring_notification_channel.email : c.id],
    google_monitoring_notification_channel.slack[*].id,
  )

  # Log-match policies require notification_rate_limit (not auto_close/notification_prompts).
  # Collapses a multi-ERROR-line failed build into a single notification per 5 min.
  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }
}

resource "google_monitoring_alert_policy" "app_error_log" {
  count = var.enable_error_log_alert && local.has_notification_channel ? 1 : 0

  project      = var.project
  display_name = "App error logs: ${var.service_name}"
  combiner     = "OR"

  documentation {
    mime_type = "text/markdown"
    subject   = "App error log on ${var.service_name}"
    content   = "Cloud Run service *${var.service_name}* emitted an ERROR-level log.\n\n[View error logs in Logs Explorer](${local.error_logs_explorer_url})"

    links {
      display_name = "Error logs"
      url          = local.error_logs_explorer_url
    }
  }

  conditions {
    display_name = "App emitted an ERROR-level log"

    condition_matched_log {
      filter = <<-EOT
        resource.type="cloud_run_revision"
        resource.labels.service_name="${var.service_name}"
        (severity>=ERROR OR jsonPayload.level>=50)
      EOT
    }
  }

  notification_channels = concat(
    [for c in google_monitoring_notification_channel.email : c.id],
    google_monitoring_notification_channel.slack[*].id,
  )

  # Log-match policies require notification_rate_limit. Collapses a burst of error logs
  # into a single notification per 5 min so a failing endpoint doesn't spam the channel.
  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }
}

resource "google_monitoring_alert_policy" "migration_failed" {
  count = var.enable_migration_alert && local.has_notification_channel ? 1 : 0

  project      = var.project
  display_name = "Migration failed: ${var.service_name}"
  combiner     = "OR"

  documentation {
    mime_type = "text/markdown"
    subject   = "Cloud Build migration failed for ${var.service_name}"
    content   = "A database *migration* build for *${var.service_name}* failed.\n\n[View build logs](${local.build_log_url})"

    links {
      display_name = "Cloud Build history"
      url          = local.build_history_url
    }
  }

  conditions {
    display_name = "Migration build failed"

    condition_matched_log {
      filter = <<-EOT
        resource.type="build"
        resource.labels.build_trigger_id="${var.migration_trigger_id}"
        severity=ERROR
      EOT

      label_extractors = {
        "build_id" = "EXTRACT(resource.labels.build_id)"
      }
    }
  }

  notification_channels = concat(
    [for c in google_monitoring_notification_channel.email : c.id],
    google_monitoring_notification_channel.slack[*].id,
  )

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }
}
