# ./modules/cloudbuild/main.tf
# This module configures Google Cloud Build for a specific service.

# --- API Enablement ---
# Ensures the Cloud Build API is enabled on the project.
resource "google_project_service" "cloudbuild_api" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"

  # Prevents Terraform from trying to disable the API on destroy.
  disable_on_destroy = false
}

# --- IAM Permissions for the Cloud Build Service Account ---

# Use a data source to get the unique email of the default Cloud Build service account.
data "google_project_service_identity" "cloudbuild_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "cloudbuild.googleapis.com"
  # This depends on the API being enabled first.
  depends_on = [google_project_service.cloudbuild_api]
}

# Grant the Cloud Build service account the "Artifact Registry Writer" role.
# This allows it to push Docker images to the specified repository.
resource "google_project_iam_member" "artifact_registry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${data.google_project_service_identity.cloudbuild_sa.email}"
}

# Grant the Cloud Build service account the "Kubernetes Engine Developer" role.
# This allows it to deploy to the GKE cluster.
resource "google_project_iam_member" "gke_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${data.google_project_service_identity.cloudbuild_sa.email}"
}

# --- Cloud Build Trigger ---

# Creates a trigger that fires on pushes to the 'main' branch of the specified GitHub repo.
resource "google_cloudbuild_trigger" "service_trigger" {
  project     = var.project_id
  name        = "${var.service_name}-main-branch-trigger"
  description = "Triggers build for ${var.service_name} on push to main branch"

  # Configuration for connecting to the source GitHub repository.
  github {
    owner = var.github_repo_owner
    name  = var.github_repo_name
    push {
      branch = "^main$"
    }
  }

  # Specifies the build configuration file to use from the repository.
  filename = "cloudbuild.yaml" # Path to the build config in the repo

  # These variables are passed into the cloudbuild.yaml file during the build process.
  substitutions = {
    _GCP_REGION   = var.gcp_region
    _REPO_NAME    = var.artifact_repo_id
    _SERVICE_NAME = var.service_name
  }
}