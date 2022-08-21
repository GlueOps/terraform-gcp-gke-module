
locals {
  project_id = data.google_projects.env_project.projects[0].project_id
}

resource "google_container_cluster" "gke" {
  project = local.project_id
  name    = "${var.workspace}-gke"

  location                    = var.region
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





resource "google_compute_firewall" "nginx" {
  project     = local.project_id
  name        = "nginx"
  network     = data.google_compute_network.network.name
  description = "Creates firewall rule needed by nginx"

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }
  source_ranges = [local.control_panel_network]
  target_tags   = local.gke_network_tags
}


module "service-account" {
  source          = "terraform-google-modules/service-accounts/google"
  version         = "4.1.1"
  project_id      = local.project_id
  names           = ["svc-gke"]
  grant_xpn_roles = false
  project_roles = [
    "${local.project_id}=>roles/logging.logWriter",
    "${local.project_id}=>roles/monitoring.metricWriter",
    "${local.project_id}=>roles/monitoring.viewer",
    "${local.project_id}=>roles/stackdriver.resourceMetadata.writer",
  ]
}

resource "google_container_node_pool" "name" {
  project = local.project_id
  name    = "primary-node-pool"

  cluster = google_container_cluster.gke.id

  initial_node_count = 2

  management {
    auto_upgrade = true
    auto_repair  = true
  }

  node_config {
    preemptible  = false
    machine_type = "e2-medium"
    disk_type    = "pd-ssd"
    disk_size_gb = "20"

    service_account = module.service-account.email
    tags            = local.gke_network_tags
  }
}



data "google_projects" "env_project" {
  filter = "lifecycleState:ACTIVE labels.environment=${var.workspace} parent.type:folder parent.id:${var.gcp_folder_id}"
}


data "google_compute_network" "network" {
  name    = "${var.workspace}-vpc"
  project = data.google_projects.env_project.projects[0].project_id
}

data "google_compute_subnetwork" "private-network" {
  name    = "${var.workspace}-${local.region}-private-subnet"
  region  = local.region
  project = data.google_projects.env_project.projects[0].project_id
}
