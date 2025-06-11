# ./modules/cloudbuild/variables.tf

variable "project_id" {
  description = "The GCP project ID where Cloud Build will run."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region for resources, used in substitution variables."
  type        = string
}

variable "service_name" {
  description = "The name of the service being built (e.g., 'fastapi-service')."
  type        = string
}

variable "github_repo_owner" {
  description = "The owner (organization or user) of the GitHub repository."
  type        = string
}

variable "github_repo_name" {
  description = "The name of the source GitHub repository."
  type        = string
}

variable "artifact_repo_id" {
  description = "The ID of the Artifact Registry repository to push images to."
  type        = string
}
