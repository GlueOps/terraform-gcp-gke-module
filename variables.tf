locals {
  project_id = data.google_projects.env_project.projects[0].project_id
}

variable "workspace" {}

data "google_projects" "env_project" {
  filter = "lifecycleState:ACTIVE labels.environment=${var.workspace} parent.type:folder parent.id:${var.gcp_folder_id}"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "The GCP region to deploy these networks into"
}


variable "gcp_folder_id" {
  type        = string
  default     = ""
  description = "The GCP Project Folder this project is within"
}

variable "control_panel_network" {
  type        = string
  default     = "10.64.96.16/28"
  description = "Master Control Panel Network"
}


variable "kubernetes_version_prefix" {
  type        = string
  default     = "1.22.8-gke.200"
  description = "Number of IPs we should manually allocate for Cloud NAT"
}



# data "google_container_engine_versions" "central1b" {
#   provider       = google-beta
#   location       = var.region
#   version_prefix = var.kubernetes_version_prefix
# }


