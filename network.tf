
resource "google_compute_firewall" "nginx" {
  project     = local.project_id
  name        = "nginx"
  network     = data.google_compute_network.network.name
  description = "Creates firewall rule needed by nginx"

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }
  source_ranges = [var.control_panel_network]
  target_tags   = local.gke_network_tags
}


data "google_compute_network" "network" {
  name    = "${var.workspace}-vpc"
  project = data.google_projects.env_project.projects[0].project_id
}

data "google_compute_subnetwork" "private-network" {
  name    = "${var.workspace}-${var.region}-private-subnet"
  region  = var.region
  project = data.google_projects.env_project.projects[0].project_id
}