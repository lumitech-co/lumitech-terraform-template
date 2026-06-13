variable "project" {
  type = string
  description = "The GCP project ID to deploy resources"
}

variable "service_name" {
  type = string
  description = "Deployed resources naming"
}

variable "topic_name" {
  type        = string
  description = "Name of the Pub/Sub topic to be created or used by the service"
}

variable "subscription_name" {
  type        = string
  description = "Name of the Pub/Sub subscription attached to the topic and used by the service"
}
