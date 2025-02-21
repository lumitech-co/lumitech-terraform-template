variable "region" {
  type        = string
  description = "Region where to deploy resources"
}

variable "service_name" {
  description = "Deployed resources naming"
  type        = string
}

variable "db_instance_name" {
  description = "DB instance name"
  type        = string
}
