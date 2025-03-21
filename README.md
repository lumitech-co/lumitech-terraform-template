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
5. **CI/CD**: Prisma database migration and deployment configurations triggered on branch updates.

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
3. **GitHub Repository Connection**: Connect your GitHub repository to GCP Cloud Build. Follow [this guide](https://cloud.google.com/build/docs/automating-builds/github/connect-repo-github?generation=1st-gen#connecting_a_github_repository).
4. **Copy Template Files**:  Copy the files from the template to your project directory. The following files are required:
    - `migration-cloudbuild.yaml` and `cloudbuild.yaml`.
    - `tf` directory files with `dev` and `modules` folders.
    - `.gitignore` with necessary files to be ignored from Terraform.
5. **Input Variables**: Update the `terraform.tfvars` file inside the `tf/dev` directory. Update the mock data with your project variables.
    - In this file, you provide the variables of the infrastructure to be created — service name, database name, GitHub repository, etc.
    - If you are using VSCode, you can install the [Terraform extension](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform). 
6. **Infrastructure Creation**: Go to `tf/dev` directory in your terminal and apply the following commands:
    1. `terraform init` - Initialize the dependencies of your project.
    2. `terraform apply` - Create the infrastructure on GCP. You will be prompted to confirm the changes. This step takes approximately 20 minutes.
    3. `terraform init -migrate-state` - Migrate the state to GCP after the infrastructure creation. The state will be stored on Google Cloud Storage instead of in local files.
7. **Save Changes**: Push the changes to your GitHub repository with `git push`. This step will trigger first deployment and migration actions on Cloud Build.
8. **Unset Temporary Image**: Set the Cloud Run dummy image variable to false after the first successful deployment. You do not need to run terraform apply again, as the new image is already in use.

## ➡️ Further Setup
### Adding Environment Variables
To provide a new secret environment variable to the Cloud Run container, proceed with the following steps:
1. Create a new secret variable in the Secret Manager. You can follow the steps in the [Secret Manager documentation](https://cloud.google.com/secret-manager/docs/creating-and-accessing-secrets#create-a-secret).
    - Add an environment prefix if the variable will be used only for the current environment. e.g. `dev-secret-name`
2. Copy the secret ID from the secret details page. Secret ID example: `projects/123456789101/secrets/dev-secret-name`.
3. Create a Terraform variable with the secret ID as its value.
```terraform
# tf/dev/variables.tf
variable "example_secret_for_cloud_run" {
  type = string
}
# ... other variable declarations
```
```terraform
# tf/dev/terraform.tfvars
example_secret_for_cloud_run = "projects/123456789102/secrets/dev-some-secret"
# ... other variables
```
4. Pass the secret ID variable to the Cloud Run module.
```terraform
# tf/dev/main.tf
module "cloud_run" {
...
  secret_vars = {
    SECRET_NAME = var.example_secret_for_cloud_run
  }
...
}
```
5. Update the infrastructure on GCP - `terraform apply` and confirm the changes.
    - This step passes the variables to the Cloud Run instance and creates an IAM role with access to the secret ID.

### Creating Different Environments
Each environment is defined as a root module with the same reusable submodules.
To create another environment (production, staging, etc.), complete the following steps:
1. Copy the `tf/dev` directory with the desired environment name (e.g., `tf/prod` or `tf/staging`).
2. Update the environment variables in `terraform.tfvars` to match the environment.
3. Proceed from **step 6** in the **Deployment Steps** section.


## 📂 Template Structure

This Terraform template is split into a **root module** (in `tf/dev`) and **submodules** (in `tf/modules`). By separating environment-specific settings from reusable infrastructure modules, you can quickly replicate environments (e.g., `tf/prod`, `tf/staging`) while keeping the same core logic in the submodules.

### `tf/dev` (Root Module)

- Holds environment-level configurations and the main `.tfvars` file for variables specific to this environment.
- References the submodules to provision resources for your chosen environment.
- You can copy this entire directory to create another environment (e.g., `tf/prod`).

### `tf/modules` (Submodules)

Each directory within `tf/modules` defines a reusable component of the infrastructure:

- `cloud-run/` – Provisions and configures Cloud Run services.  
- `cloud-sql/` – Manages a Cloud SQL PostgreSQL instance.  
- `network/` – Sets up a VPC network.  
- `project-api/` – Enables project-level APIs.
- `secret/` – Generate secrets in Secret Manager.

```
.
├── cloudbuild.yaml
├── Dockerfile
├── LICENSE
├── migration-cloudbuild.yaml
├── README.md
└── tf
    ├── dev
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── terraform.tfvars
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
