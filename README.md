![image](https://github.com/user-attachments/assets/e2b5fd98-bb13-481a-8b8a-85f9d64183e0)
![license](https://img.shields.io/github/license/lumitech-co/lumitech-terraform-template?style=flat)
![maintenance](https://img.shields.io/badge/maintenance-active-blue?style=flat)

# Lumitech Terraform Template 
Welcome to the Lumitech Terraform Template. This template offers a solution for deploying a Node.js server and a PostgreSQL database on Google Cloud Platform (GCP) using Terraform, an infrastructure as code tool. By leveraging Terraform's language (HCL), the infrastructure can be deployed across different environments like development, production, staging ensuring that the correct configuration is preserved.

### About Lumitech
Lumitech is a custom software development company providing professional services worldwide. We partner with technology businesses globally helping them to build successful engineering teams and create innovative software products. We’re a global team of software engineers, AI and ML specialists, product managers, and technology experts who have achieved a 600% growth rate since 2022. When a rocket launches toward the moon, it doesn’t stop halfway. Neither do we.

## ⚙ Infrastructure Overview

The infrastructure includes the following components:

1. **VPC Network**: A Virtual Private Cloud network to securely connect your resources.
2. **Cloud Run**: A fully managed environment for deploying and scaling containerized applications.
3. **Cloud SQL**: A fully managed relational database service for PostgreSQL.
4. **IAM Roles**: Identity and Access Management roles for handling migrations, deployment, and secrets access.
5. **CI/CD**: Pirsma database migration and deployment configurations triggered on branch updates.

## 📝 Prerequisites

Before you begin, ensure you have the following prerequisites:

- **Terraform CLI**: Install Terraform by following the [installation guide](https://developer.hashicorp.com/terraform/install).
- **gcloud CLI**: Install the Google Cloud SDK by following the [installation guide](https://cloud.google.com/sdk/docs/install).
- **Basic Knowledge of Terraform**: Familiarize yourself with Terraform by following [this tutorial](https://developer.hashicorp.com/terraform/tutorials/docker-get-started).
- **GCP Project**: Create a Google Cloud Platform project with billing enabled. Follow the [creation guide](https://developers.google.com/workspace/guides/create-project#project) and [billing setup guide](https://developers.google.com/workspace/guides/create-project#billing).

## 🚀 Deployment Steps

1. **IAM Roles**: Ensure your IAM Principal has the following roles:
    - Cloud Run Admin
    - Editor
    - Project IAM Admin
    - Secret Manager Admin
    - Service Account Admin
    - Service Networking Admin
2. **gcloud Authentication**: Authenticate to the _gcloud_ CLI in your terminal - `gcloud auth login`. A detailed guide you can find [here](https://cloud.google.com/docs/authentication/gcloud#local).
3. **Github Repository Connection**: Connect your Github repository to GCP Cloudbuild. Follow [this guide](https://cloud.google.com/build/docs/automating-builds/github/connect-repo-github?generation=1st-gen#connecting_a_github_repository).
4. **Copy Template Files**:  Copy the files from the template to your project directory. The following files are required:
    - `migration-cloudbuild.yaml` and `cloudbuild.yaml`.
    - `tf` directory files with `dev` and `modules` folders.
    - `.gitignore` with necessary files to be ignored from Terraform.
5. **Input Variables**: Update the `terraform.tfvars` file inside the `tf/dev` directory. Update the mock data with your project variables.
    - In this file, you provide the variables of the infrastructure to be created — service name, database name, Github repository, etc.
    - If you are using VSCode, you can install the [Terraform extension](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform). 
6. **Infrastructure Creation**: Go to `tf/dev` directory in your terminal and apply the following commands:
    1. `terraform init` - Initialize the dependencies of your project.
    2. `terraform apply` - Create the infrastructure on GCP. You will be prompted to confirm the changes. This step takes approximately 20 minutes.
    3. `terraform init -migrate-state` - Migrate the state to GCP after the infrastructure creation. All the state will be stored on Google Cloud Storage instead of local files.
7. **Save Changes**: Push the changes to your Github repository with `git push`. This step will trigger first deployment and migration actions on Cloud Build.
8. **Unset Temporary Image**: Set cloud run dummy image variable to false after a successful first deployment. (No `terraform apply` is necessary since the new image is already set.)

## Guides
### Adding Environment Variables
To provide new environment variable to the Cloud Run container, proceed with the following steps:
1. Create a new secret variable in the Secret Manager. A guide with the steps you can find in the [Secret Manager documentation](https://cloud.google.com/secret-manager/docs/creating-and-accessing-secrets#create-a-secret).
    - Add an environment prefix if the variable will be used only for the current environment. e.g. `dev-secret-name`
2. Copy the secret ID from the secret details page. Secret id example: `projects/123456789101/secrets/dev-secret-name`.
3. Create a Terraform variable with the secret ID as its value.
```terraform
# variables.tf
variable "example_secret_for_cloud_run" {
  type = string
}
# ... other variables declaration
```
```terraform
# terraform.tfvars
example_secret_for_cloud_run = "projects/123456789102/secrets/dev-some-secret"
# ... other variables
```
4. Pass the secret id variable to the Cloud Run module.
```terraform
# main.tf
module "cloud_run" {
...
  secret_vars = {
    SECRET_NAME = var.example_secret_for_cloud_run
  }
...
}
```
5. Update the infrastructure on GCP - `terraform apply` and confirm the changes.
    - This step must update the passed vairables to the Cloud Run instance and create an IAM role for the provided secret ID.


### Creating Different Environments
Each environment represents a root module with the same set of modules.
To create another environment (production, staging, etc.), complete the following steps:
1. Copy the `tf/dev` directory with the desired environment naming - e.g. `tf/prod` or `tf/staging`.
2. Update the environment variables in `terraform.tfvars` to match the environment.
3. Proceed from the **6-th step** in the **Deployment Steps** section.


## 📂 Template Structure

```
.
├── cloudbuild.yaml # Configuration for Cloud Build Deployments
├── Dockerfile
├── migration-cloudbuild.yaml # Configuration for Cloud Build Database Migrations
├── package.json
├── package-lock.json
├── README.md
└── tf
    ├── dev
    │   ├── example.tfvars # Example Terraform Variables File
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── modules
        ├── cloud-run
        │   ├── iam.tf
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── cloud-sql
        │   ├── iam.tf
        │   ├── main.tf
        │   ├── migration.tf
        │   ├── outputs.tf
        │   ├── secrets.tf
        │   └── variables.tf
        ├── network
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── project-api
        │   └── main.tf
        └── secret
            ├── main.tf
            └── variables.tf
```

## ✨ Related Documentation
- [General style and structure guidelines](https://cloud.google.com/docs/terraform/best-practices/general-style-structure) - Google Cloud best practices for Terraform configurations.
- [Root modules](https://cloud.google.com/docs/terraform/best-practices/root-modules) - Google Cloud best practices for Root modules and Terraform structure.
