module "project-iam" {
  source   = "github.com/terraform-google-modules/terraform-google-iam//modules/projects_iam?ref=9b9eacfa2b4f849b5ef183cf5124b1e72aa72363" # v8.3.0
  projects = [var.project_id]
  mode     = "additive"

  bindings = {
    for role in ["roles/logging.logWriter", "roles/monitoring.metricWriter"] :
    role => ["serviceAccount:${google_service_account.privoxy.account_id}@${var.project_id}.iam.gserviceaccount.com"]
  }
}

module "kms-iam" {
  source          = "github.com/terraform-google-modules/terraform-google-iam//modules/kms_crypto_keys_iam?ref=9b9eacfa2b4f849b5ef183cf5124b1e72aa72363" # v8.3.0
  kms_crypto_keys = [module.kms.keys["privoxy-disk-key"]]
  mode            = "authoritative"

  bindings = {
    "roles/cloudkms.cryptoKeyEncrypterDecrypter" = [
      google_service_account.privoxy.member,
      "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com",
    ]
  }
}
