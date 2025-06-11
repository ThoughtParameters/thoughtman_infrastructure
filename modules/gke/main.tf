# --------------------------------------------------------------------------------------------------
# modules/gke/main.tf - GKE Autopilot Cluster
# --------------------------------------------------------------------------------------------------
resource "google_container_cluster" "primary" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.gcp_region

  # We can't configure a GKE Autopilot cluster to use a specific zone.
  # The cluster is regional.
  enable_autopilot = true

  # Networking
  network    = var.network_id
  subnetwork = var.subnetwork_id
  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    # GKE Autopilot manages the pod and service CIDR ranges automatically.
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false # Keep the control plane public for easier access
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  master_authorized_networks_config {} # Allows access from all IPs, can be restricted.

  release_channel {
    channel = "REGULAR"
  }
}
