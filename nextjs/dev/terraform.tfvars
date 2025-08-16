project = "project-id"        // GCP project ID, e.g. tokyo-rain-123
region  = "europe-central2"   // Region where to deploy resources, e.g. europe-central2
zone    = "europe-central2-a" // Region zone where to deploy resources, e.g. europe-central2-a

environment  = "dev"                 // dev, prod, staging, etc. This environment will be added as a prefix for the created resources. 
service_name = "dev-my-project-name" // Service name will be used as a name for Cloud run, VPC, Service Accounts, IAM roles.

// Github repository for deployment configuration
gh_owner       = "lumitech-co"             // Github owner of the repository.
gh_repo_name   = "project-repository-name" // Repository name.
gh_branch_name = "main"                    // Branch name to trigger new revisions from.

// Cloud Run module configuration
cloud_run_min_instance_count    = 0                     // Development - 0, production - 1. If there are 0 instances, the application will go to sleep to reduce costs.
cloud_run_instance_limit_memory = "2Gi"                 // The amount of memory to allocate to a single Cloud Run instance.
cloud_run_instance_limit_cpus   = 1                     // The number of CPUs to allocate to a single Cloud Run instance.

cloud_run_set_dummy_image = true // Set to TRUE when initially deploying the infrastructure in order to avoid an error. Update to false after the first deployment.

// Environment variables
next_public_api_url  = "https://jsonplaceholder.typicode.com"
