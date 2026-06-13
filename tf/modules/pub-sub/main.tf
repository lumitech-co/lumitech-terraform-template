resource "google_pubsub_topic" "topic" {
  name    = "${var.service_name}-${var.topic_name}"
  project = var.project
}

resource "google_pubsub_subscription" "subscription" {
  name    = "${var.service_name}-${var.subscription_name}"
  topic   = google_pubsub_topic.topic.name
  project = var.project
}