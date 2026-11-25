module "kms" {
  source              = "github.com/terraform-google-modules/terraform-google-kms?ref=ef6e0eda70324827d72171bc96d76bccac44a698" # v4.2.1
  project_id          = var.project_id
  location            = var.region
  keyring             = "privoxy-keyring"
  keys                = ["privoxy-disk-key"]
  key_rotation_period = "7776000s"
  prevent_destroy     = true
}
