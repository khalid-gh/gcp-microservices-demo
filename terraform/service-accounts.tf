resource "google_service_account" "privoxy" {
  project      = var.project_id
  account_id   = "privoxy"
  display_name = "Privoxy service account"
}
