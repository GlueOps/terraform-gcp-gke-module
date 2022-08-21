# terraform-gcp-gke-module

Terraform Module to deploy a Kubernetes/GKE Cluster into GCP (Google Cloud Platform)

Usage
```

locals {
  gcp_folder_id = "XXXXXXXXXXXX"
}

module "gke" {
  source = "git::https://github.com/GlueOps/terraform-gcp-gke-module.git"

  workspace     = var.workspace
  region        = "us-central1"
  gcp_folder_id = local.gcp_folder_id
}
```