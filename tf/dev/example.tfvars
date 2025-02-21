project = "project-id"
region  = "europe-central2"
zone    = "europe-central2-a"

environment      = "dev"                 // dev, prod, staging etc.
service_name     = "dev-my-project-name" // Will be used as a name for Cloud run, VPC, service accounts, IAM roles.
db_instance_name = "dev-database-name"

// Github repository for deployment configuration
gh_owner       = "lumitech-co"
gh_repo_name   = "project-name-api"
gh_branch_name = "main"

// Cloud SQL module configuration
cloud_sql_db_deletion_protection = true
cloud_sql_tier                   = "db-f1-micro"

// Cloud Run module configuration
cloud_run_application_url       = "http://0.0.0.0:3001" // Update to hardcoded API URL after resources creation.
cloud_run_min_instance_count    = 0
cloud_run_instance_limit_memory = "1Gi"
cloud_run_instance_limit_cpus   = 1

cloud_run_set_dummy_image = true // Set to true when initially deploying the application in order to avoid an error. Update to false after the first deployment.
