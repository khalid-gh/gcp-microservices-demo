module "cloud-nat" {
  source                             = "github.com/terraform-google-modules/terraform-google-cloud-nat?ref=4527cee64841eb2fb7a9f568311586210af43f6c" # v7.1.0
  name                               = "demo-nat"
  project_id                         = var.project_id
  region                             = var.region
  router                             = "demo-nat-router"
  create_router                      = true
  network                            = module.vpc.network_self_link
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  log_config_enable                  = true
  log_config_filter                  = "ERRORS_ONLY"

  subnetworks = [
    {
      name                     = module.vpc.subnets["${var.region}/gke-demo-subnet"].self_link
      source_ip_ranges_to_nat  = ["ALL_IP_RANGES"]
      secondary_ip_range_names = []
    },
    {
      name                     = module.vpc.subnets["${var.region}/privoxy-subnet"].self_link
      source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE"]
      secondary_ip_range_names = []
    }
  ]
}
