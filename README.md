This template offers a solution for deploying a Node.js server and a PostgreSQL database on Google Cloud Platform (GCP) using Terraform, an infrastructure as code tool. By leveraging Terraform's language (HCL), the infrastructure can be deployed across different environments like development, production, staging ensuring that the correct configuration is preserved.

## Infrastructure Overview

The infrastructure includes the following components:

1. **VPC Network**: A Virtual Private Cloud network to securely connect your resources.
2. **Cloud Run**: A fully managed environment for deploying and scaling containerized applications.
3. **Cloud SQL**: A fully managed relational database service for PostgreSQL.
4. **IAM Roles**: Identity and Access Management roles for handling migrations, deployment, and secrets access.
5. **CI/CD**: Pirsma database migration and deployment configurations triggered on branch updates.

## Prerequisites

Before you begin, ensure you have the following prerequisites:

- **Terraform CLI**: Install Terraform by following the [installation guide](https://developer.hashicorp.com/terraform/install).
- **gcloud CLI**: Install the Google Cloud SDK by following the [installation guide](https://cloud.google.com/sdk/docs/install).
- **Basic Knowledge of Terraform**: Familiarize yourself with Terraform by following [this tutorial](https://developer.hashicorp.com/terraform/tutorials/docker-get-started).
- **GCP Project**: Create a Google Cloud Platform project with billing enabled. Follow the [creation guide](https://developers.google.com/workspace/guides/create-project#project) and [billing setup guide](https://developers.google.com/workspace/guides/create-project#billing).

## Deployment Steps

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
5. **Input Variables**: Create a `terraform.tfvars` file inside `tf/dev` directory and copy the contents of `example.tfvars`. Update the mock data with your project variables.
    - In this file, you provide the variables of the infrastructure to be created—service name, database name, Github repository, etc.
    - If you are using VSCode, you can install the [Terraform extension](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform). 
6. **Infrastructure Creation**: Go to `tf/dev` directory in your terminal and apply the following commands:
    1. `terraform init` - Initialize the dependencies of your project
    2. `terraform apply` - Create the infrastructure on GCP. You will be prompted to confirm the changes. This step takes approximately 20 minutes.
    3. `terraform init -migrate-state` - Migrate the state to GCP after the infrastructure creation. All the state will be stored on Google Cloud Storage instead of local files.
7. **Save Changes**: Push the changes to your Github repository with `git push`. 

### Template Structure

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
