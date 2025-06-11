# --------------------------------------------------------------------------------------------------
# modules/vpc/variables.tf
# --------------------------------------------------------------------------------------------------
variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "network_name" {
  description = "The name for the VPC network."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region to deploy resources in."
  type        = string
}

variable "subnet_ip_cidr" {
  description = "The IP CIDR range for the subnetwork."
  type        = string
}