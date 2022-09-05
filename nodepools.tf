resource "google_container_node_pool" "name" {
  project = local.project_id
  name    = "primary-node-pool"

  cluster = google_container_cluster.gke.id

  initial_node_count = 3

  management {
    auto_upgrade = true
    auto_repair  = true
  }

  node_config {
    spot         = var.spot_instances
    machine_type = "e2-medium"
    disk_type    = "pd-ssd"
    disk_size_gb = "20"

    service_account = module.service-account.email
    tags            = local.gke_network_tags
  }
}
