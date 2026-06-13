<div align="center">
 <img width="374" src="https://github.com/user-attachments/assets/2ab91ccf-ce8e-4f2e-94a8-347e53746e5b" />
</div>

# Lumitech Terraform Template 
This template offers a solution for deploying a Node.js server and a PostgreSQL database on Google Cloud Platform (GCP) using Terraform, an infrastructure as code tool. By leveraging Terraform's language (HCL), the infrastructure can be deployed across different environments like development, production, staging ensuring that the correct configuration is preserved.

### About Lumitech
[Lumitech](https://lumitech.co/) is a custom software development company providing professional services worldwide. We partner with technology businesses globally helping them to build successful engineering teams and create innovative software products. We’re a global team of software engineers, AI and ML specialists, product managers, and technology experts who have achieved a 600% growth rate since 2022. When a rocket launches toward the moon, it doesn’t stop halfway. Neither do we.

## ⚙ Infrastructure Overview

The infrastructure includes the following components:

1. **VPC Network**: A Virtual Private Cloud network to securely connect your resources.
2. **Cloud Run**: A fully managed environment for deploying and scaling containerized applications.
3. **Cloud SQL**: A fully managed relational database service for PostgreSQL.
4. **Redis (Memorystore)**: A managed in-memory cache attached to the VPC network.
5. **Cloud Storage Buckets**: Private and public buckets for file storage, with CORS configured for browser uploads.
6. **Cloud Scheduler**: Cron jobs that call the API on a schedule (signals, syncs, snapshots, etc.).
7. **Monitoring & Alerting**: Cloud Monitoring alert policies (Cloud Run 5xx, app error logs, deploy/migration build failures) delivered to email and/or Slack. See [Monitoring & Alerting](#-monitoring--alerting).
8. **IAM Roles**: Identity and Access Management roles for handling migrations, deployment, and secrets access.
9. **CI/CD**: Prisma database migration and deployment configurations triggered on branch updates.

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


## 📊 Monitoring & Alerting

The `monitoring/` module provisions [Cloud Monitoring](https://cloud.google.com/monitoring/docs) notification channels and alert policies. Alerts fire to **email**, **Slack**, or both — whatever you configure. If neither an email nor a Slack channel is set, the build/migration/error-log alerts are simply not created.

### What is monitored

| Alert policy | Trigger | Type |
| --- | --- | --- |
| **Cloud Run 5xx errors** | The service returns any `5xx` response (request count > 0, 60s window). | Metric threshold |
| **App error logs** | The app emits an `ERROR`-level log. Matches Cloud Logging `severity>=ERROR` **or** Pino's `jsonPayload.level>=50` (50 = error, 60 = fatal), because Cloud Run maps stdout to `INFO`. | Log match |
| **Deploy failed** | The service's Cloud Build **deploy** trigger produces an `ERROR` log. | Log match |
| **Migration failed** | The service's Cloud Build **migration** trigger produces an `ERROR` log. | Log match |

Every alert's notification includes a deep link to the exact Logs Explorer query or the specific failed build, so you can jump straight to the relevant logs from Slack/email.

The 5xx alert is always created. The other three are gated by `enable_deploy_alert`, `enable_migration_alert`, and `enable_error_log_alert` (all enabled in `tf/dev/main.tf` and `tf/prod/main.tf`).

### Configuration

The module is wired in each root module (`tf/dev/main.tf`, `tf/prod/main.tf`) via `module "monitoring"`. The values you actually set per environment live in `terraform.tfvars`:

```terraform
# tf/<env>/terraform.tfvars

# Email recipients. Empty list = email channel disabled (Slack only).
alert_emails = ["devops@example.com"]

# Slack channel + the Secret Manager secret holding the Slack bot token.
# Empty slack_channel_name = Slack disabled (email only).
slack_channel_name         = "#tolmete-alerts-dev"
slack_auth_token_secret_id = "projects/97812123028/secrets/SLACK_ALERTING_TOKEN"
```

Key module variables (see `tf/modules/monitoring/variables.tf`):

| Variable | Purpose |
| --- | --- |
| `alert_emails` | List of emails to notify. Empty disables the email channel. |
| `slack_channel_name` | Slack channel to post to (e.g. `#alerts`). Empty disables Slack. |
| `slack_auth_token_secret_id` | Full Secret Manager secret path holding the Slack bot token. **Required** when `slack_channel_name` is set. |
| `enable_deploy_alert` / `deploy_trigger_id` | Toggle + Cloud Build deploy trigger ID for the deploy-failure alert. |
| `enable_migration_alert` / `migration_trigger_id` | Toggle + Cloud Build migration trigger ID for the migration-failure alert. |
| `enable_error_log_alert` | Toggle the app `ERROR`-log alert. |

### Tutorial: Creating Slack alerts

Follow these steps to wire alerts into a Slack channel.

1. **Create (or pick) a Slack channel** for alerts, e.g. `#tolmete-alerts-dev`.

2. **Create a Slack app with a bot token.**
    1. Go to <https://api.slack.com/apps> → **Create New App** → **From scratch**. Name it (e.g. `GCP Alerts`) and select your workspace.
    2. Open **OAuth & Permissions** → **Scopes** → **Bot Token Scopes** and add `chat:write`.
    3. Click **Install to Workspace** and authorize. Copy the **Bot User OAuth Token** (starts with `xoxb-`).
    4. In Slack, invite the bot to the channel: `/invite @GCP Alerts` in `#tolmete-alerts-dev`.

    > Alternatively, Cloud Monitoring can connect Slack via its own OAuth flow when you create a Slack channel in the console — but storing your own bot token in Secret Manager (below) keeps the setup fully in Terraform and reproducible.

3. **Store the token in Secret Manager.** Create a secret (e.g. `SLACK_ALERTING_TOKEN`) and add the bot token as a secret version:
    ```bash
    gcloud secrets create SLACK_ALERTING_TOKEN --replication-policy=automatic --project=<project-id>
    printf '%s' 'xoxb-your-bot-token' | gcloud secrets versions add SLACK_ALERTING_TOKEN --data-file=- --project=<project-id>
    ```
    Copy the full secret path from the secret's detail page, e.g. `projects/97812123028/secrets/SLACK_ALERTING_TOKEN`.

4. **Point the environment at the channel and secret** in `tf/<env>/terraform.tfvars`:
    ```terraform
    slack_channel_name         = "#tolmete-alerts-dev"
    slack_auth_token_secret_id = "projects/97812123028/secrets/SLACK_ALERTING_TOKEN"
    ```

5. **Grant the channel access (one-time).** The first time you save a Slack secret, ensure the secret exists before `terraform apply` — the module reads the token via a `google_secret_manager_secret_version` data source at plan time. Your Terraform principal needs `secretmanager.versions.access` on that secret.

6. **Apply.** From `tf/<env>`:
    ```bash
    terraform apply
    ```
    This creates the `Slack Alert - #tolmete-alerts-dev` notification channel and attaches it to all alert policies.

7. **Verify.** In the GCP Console go to **Monitoring → Alerting → Edit notification channels**, find the Slack channel, and click **Send test notification**. You should see a message appear in the Slack channel.

To **disable** Slack later, clear `slack_channel_name = ""` and re-apply. The channels use `force_delete = true`, so they can be removed even while still referenced by an alert policy.

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
