# --------------------------------------------------------------------------------------------------
# variables.tf - Root module variables
# --------------------------------------------------------------------------------------------------

variable "gcp_project_id" {
  description = "The GCP project ID to deploy resources into."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region to deploy resources in."
  type        = string
  default     = "us-central1"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token."
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the domain."
  type        = string
}

variable "domain_name" {
  description = "The domain name to manage in Cloudflare."
  type        = string
  default     = "thoughtparameters.com"
}

