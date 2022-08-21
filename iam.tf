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