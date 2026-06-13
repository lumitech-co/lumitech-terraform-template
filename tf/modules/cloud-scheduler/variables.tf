variable "name" {
  description = "Name of the cron job"
  type        = string
}

variable "project" {
  type        = string
  description = "The GCP project ID to deploy resources"
}

variable "description" {
  description = "Description of the cron job"
  type        = string
  default     = ""
}

variable "schedule" {
  description = "Cron expression schedule"
  type        = string
}

variable "time_zone" {
  description = "Time zone for the job"
  type        = string
  default     = "Etc/UTC"
}

variable "http_method" {
  description = "HTTP method"
  type        = string
  default     = "GET"
}

variable "uri" {
  description = "Target URL"
  type        = string
}

variable "headers" {
  description = "Optional HTTP headers"
  type        = map(string)
  default     = {}
}

variable "body" {
  description = "Optional request body"
  type        = string
  default     = null
}

variable "target_type" {
  description = "Target type: http or pubsub"
  type        = string
  default     = "http"
}