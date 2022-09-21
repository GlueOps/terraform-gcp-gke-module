
resource "google_container_cluster" "gke" {
  project = local.project_id
  name    = "${var.workspace}-gke"

  location                    = var.run_masters_in_single_zone ? format("%s%s", var.region, "-a") : var.region
  min_master_version          = var.kubernetes_version_prefix
  remove_default_node_pool    = true
  initial_node_count          = 1
  enable_intranode_visibility = true

  release_channel {
    channel = "STABLE"
  }

  network    = data.google_compute_network.network.id
  subnetwork = data.google_compute_subnetwork.private-network.id

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.control_panel_network
    master_global_access_config {
      enabled = true
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.workspace}-${var.region}-kubernetes-pods"
    services_secondary_range_name = "${var.workspace}-${var.region}-kubernetes-services"
  }

  node_config {
    service_account = module.service-account.email
    tags            = ["gke-${var.workspace}"]
    spot            = var.spot_instances

  }


  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  resource_labels = {}

  lifecycle {
    ignore_changes = [
      node_config,
    ]
  }
}
