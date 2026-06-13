project = "project-id"        // GCP project ID, e.g. tokyo-rain-123
project_number = 00000000
region  = "us-central1"   // Region where to deploy resources, e.g. europe-central2
zone    = "us-central1-a" // Region zone where to deploy resources, e.g. europe-central2-a

environment      = "dev"                 // dev, prod, staging, etc. This environment will be added as a prefix for the created resources. 
service_name     = "dev-api" // Service name will be used as a name for Cloud run, VPC, Service Accounts, IAM roles.
db_instance_name = "dev-db"   // DB instance name will be used as a name for Cloud SQL instance.

// Either provide list of emails or slack channel with app token
// Alerting module configuration (deploy build failures -> email + Slack)
alert_emails = []
slack_channel_name         = "#channel-name"
slack_auth_token_secret_id = "projects/97812123028/secrets/SLACK_TOKEN"

public_bucket_name                 = "dev-public"
public_bucket_cors_allowed_origins = ["https://localhost:3000", "http://localhost:3000", "https://127.0.0.1:3000", "http://127.0.0.1:3000"]

// Github repository for deployment configuration
gh_owner       = "lumitech-co"             // Github owner of the repository.
gh_repo_name   = "dev-api" // Repository name.
gh_branch_name = "dev"                    // Branch name to trigger new revisions from.

// Cloud SQL module configuration
cloud_sql_db_deletion_protection = true          // Enable deletion protection for the Cloud SQL instance. Production version must have this enabled.
cloud_sql_tier                   = "db-f1-micro" // Cloud SQL tier for the instance. Default is the cheapest tier. More options: https://cloud.google.com/sdk/gcloud/reference/sql/tiers/list
cloud_sql_allowed_ips            = []
cloud_sql_database_flags         = [
  {
    name  = "max_connections"
    value = "100"
  }
]

// Cloud Run module configuration
cloud_run_application_url       = "http://0.0.0.0:3001" // Update to the hardcoded API URL after resources creation.
cloud_run_min_instance_count    = 0                     // Development - 0, production - 1. If there are 0 instances, the application will go to sleep to reduce costs.
cloud_run_instance_limit_memory = "1Gi"                 // The amount of memory to allocate to a single Cloud Run instance.
cloud_run_instance_limit_cpus   = 1                     // The number of CPUs to allocate to a single Cloud Run instance.

cloud_run_set_dummy_image = true // Set to TRUE when initially deploying the infrastructure in order to avoid an error. Update to false after the first deployment.

api_environment_variables = {
    cors_origin="http://localhost:3000,http://127.0.0.1:3000"
}

// Cloud Run Secret Manager secrets
api_secret_keys = {
    # google_places_api_key = "projects/97812123028/secrets/GOOGLE_PLACES_API_KEY"
}
