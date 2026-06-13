variable "project" {
  type        = string
  description = "The GCP project ID to deploy resources"
}

variable "service_name" {
  description = "Cloud Run service name to monitor for 5xx errors"
  type        = string
}

variable "alert_emails" {
  description = "Email addresses to notify on alerts. Empty disables email alerts."
  type        = list(string)
  default     = []
}

variable "slack_channel_name" {
  description = "Slack channel to post 5xx alerts to (e.g. #alerts). Empty disables Slack."
  type        = string
  default     = ""
}

variable "slack_auth_token_secret_id" {
  description = "Secret Manager secret id holding the Slack auth token for the alert channel"
  type        = string
  default     = ""

  validation {
    condition     = var.slack_channel_name == "" || var.slack_auth_token_secret_id != ""
    error_message = "slack_auth_token_secret_id is required when slack_channel_name is set."
  }
}

variable "enable_deploy_alert" {
  description = "Create a log-based alert when this service's Cloud Build deploy fails."
  type        = bool
  default     = false
}

variable "deploy_trigger_id" {
  description = "Cloud Build deploy trigger ID (used in the failure log filter)."
  type        = string
  default     = ""
}

variable "enable_migration_alert" {
  description = "Create a log-based alert when this service's Cloud Build migration fails."
  type        = bool
  default     = false
}

variable "migration_trigger_id" {
  description = "Cloud Build migration trigger ID (used in the failure log filter)."
  type        = string
  default     = ""
}

variable "enable_error_log_alert" {
  description = "Create a log-based alert when the app emits an ERROR-level (Pino level>=50) log."
  type        = bool
  default     = false
}
