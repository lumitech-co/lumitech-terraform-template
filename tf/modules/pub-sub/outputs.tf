output "topic" {
  value = google_pubsub_topic.topic.name
}

output "subscription" {
  value = google_pubsub_subscription.subscription.name
}