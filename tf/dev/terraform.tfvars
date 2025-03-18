project = "project-id"        // GCP project ID, e.g. tokyo-rain-123
region  = "europe-central2"   // Region where to deploy resources, e.g. europe-central2
zone    = "europe-central2-a" // Region zone where to deploy resources, e.g. europe-central2-a

environment      = "dev"                 // dev, prod, staging, etc. This environment will be added as a prefix for the created resources. 
service_name     = "dev-my-project-name" // Service name will be used as a name for Cloud run, VPC, Service Accounts, IAM roles.
db_instance_name = "dev-database-name"   // DB instance name will be used as a name for Cloud SQL instance.

// Github repository for deployment configuration
gh_owner       = "lumitech-co"             // Github owner of the repository.
gh_repo_name   = "project-repository-name" // Repository name.
gh_branch_name = "main"                    // Branch name to trigger new revisions from.

// Cloud SQL module configuration
cloud_sql_db_deletion_protection = true          // Enable deletion protection for the Cloud SQL instance. Production version must have this enabled.
cloud_sql_tier                   = "db-f1-micro" // Cloud SQL tier for the instance. Default is the cheapest tier. More options: https://cloud.google.com/sdk/gcloud/reference/sql/tiers/list

// Cloud Run module configuration
cloud_run_application_url       = "http://0.0.0.0:3001" // Update to the hardcoded API URL after resources creation.
cloud_run_min_instance_count    = 0                     // Development - 0, production - 1. If there are 0 instances, the application will go to sleep to reduce costs.
cloud_run_instance_limit_memory = "1Gi"                 // The amount of memory to allocate to a single Cloud Run instance.
cloud_run_instance_limit_cpus   = 1                     // The number of CPUs to allocate to a single Cloud Run instance.

cloud_run_set_dummy_image = true // Set to TRUE when initially deploying the infrastructure in order to avoid an error. Update to false after the first deployment.

// Cloud Run Secret Manager secrets
// example_secret_for_cloud_run = "projects/123456789102/secrets/dev-some-secret" // Provide custom secrets for the Cloud Run service.
