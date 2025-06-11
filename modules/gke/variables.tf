# --------------------------------------------------------------------------------------------------
# modules/gke/variables.tf
# --------------------------------------------------------------------------------------------------
variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "cluster_name" {
  description = "The name for the GKE cluster."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region for the cluster."
  type        = string
}

variable "network_id" {
  description = "The ID of the VPC network."
  type        = string
}

variable "subnetwork_id" {
  description = "The ID of the VPC subnetwork."
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation to use for the GKE master."
  type        = string
}