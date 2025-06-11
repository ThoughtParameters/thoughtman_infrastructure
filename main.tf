# --------------------------------------------------------------------------------------------------
# main.tf - Root module
# --------------------------------------------------------------------------------------------------

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.3"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
  }

  # Configure the GCS backend for remote state storage
  backend "gcs" {
    bucket = "your-terraform-state-bucket-name" # <-- IMPORTANT: Replace with a unique GCS bucket name
    prefix = "terraform/state"
  }
}

# --- Provider Configuration ---

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "google_client_config" "default" {}

data "google_container_cluster" "gke_cluster" {
  name     = module.gke.cluster_name
  location = var.gcp_region
  project  = var.gcp_project_id
  depends_on = [
    module.gke
  ]
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://{data.google_container_cluster.gke_cluster.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)
  }
}

# --- API Service Enablement ---
# This ensures that all required APIs are enabled for the project.

resource "google_project_service" "gke_api" {
  project            = var.gcp_project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifact_registry_api" {
  project            = var.gcp_project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "secret_manager_api" {
  project            = var.gcp_project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

# The cloudbuild API is enabled within the cloudbuild module,
# but it's good practice to list it here for clarity if you wish.
# resource "google_project_service" "cloudbuild_api" {
#   project            = var.gcp_project_id
#   service            = "cloudbuild.googleapis.com"
#   disable_on_destroy = false
# }

# --- Module Instantiation ---

module "vpc" {
  source     = "./modules/vpc"

  # This module creates a VPC and subnetwork for the GKE cluster.
  # It also configures the necessary firewall rules.
  # Ensure the VPC and subnet CIDR ranges do not overlap with existing networks.
  # Adjust the CIDR ranges as necessary for your network design.
  # The VPC is regional, so it will span all zones in the specified region.
  # Ensure the region matches the GKE cluster region.
  # Adjust the network name and CIDR as necessary for your design.
  #
  # Note: The VPC and subnet are created in the same region as the GKE cluster.
  gcp_region = var.gcp_region
  network_name = "thoughtman-vpc"
  project_id = var.gcp_project_id
  subnet_ip_cidr = "10.201.0.0/24"
}

module "gke" {
  source        = "./modules/gke"

  gcp_region    = var.gcp_region
  network_id    = module.vpc.network_id
  subnetwork_id = module.vpc.subnetwork_id
  cluster_name  = "thoughtman-gke-cluster"
  project_id    = var.gcp_project_id
  master_ipv4_cidr_block = "237.84.2.176/28"

  # This module depends on the GKE API being enabled first.
  depends_on    = [google_project_service.gke_api, module.vpc]
}

resource "google_artifact_registry_repository" "my_repo" {
  location      = var.gcp_region
  repository_id = "thoughtman-app-repo"
  description   = "Docker repository for my thoughtman applications"
  format        = "DOCKER"
  project       = var.gcp_project_id

  # Depends on the Artifact Registry API being enabled.
  depends_on = [google_project_service.artifact_registry_api]
}
