module "vpc" {
  source       = "github.com/terraform-google-modules/terraform-google-network?ref=91352bed3014ddbfb323d979b6413a90e7253acf" # v18.3.1
  project_id   = var.project_id
  network_name = "gke-demo-vpc"

  subnets = [
    {
      subnet_name           = "gke-demo-subnet"
      subnet_ip             = "10.0.0.0/18"
      subnet_region         = var.region
      subnet_private_access = true
    },
    {
      subnet_name           = "privoxy-subnet"
      subnet_ip             = "10.0.64.0/28"
      subnet_region         = var.region
      subnet_private_access = true
    }
  ]

  secondary_ranges = {
    "gke-demo-subnet" = [
      {
        range_name    = "gke-demo-subnet-pods"
        ip_cidr_range = "10.48.0.0/14"
      },
      {
        range_name    = "gke-demo-subnet-services"
        ip_cidr_range = "10.52.0.0/20"
      }
    ]
  }

  ingress_rules = [
    {
      name          = "allow-iap-privoxy"
      description   = "Allow IAP TCP forwarding to Privoxy"
      source_ranges = ["35.235.240.0/20"]
      target_tags   = ["privoxy"]
      allow = [{
        protocol = "tcp"
        ports    = ["8118"]
      }]
    },
    {
      name          = "gke-demo-cluster-istio-webhook"
      description   = "Allow the GKE control plane to reach the Istio admission webhook"
      source_ranges = [coalesce(module.gke.master_ipv4_cidr_block, "${module.gke.endpoint}/32")]
      target_tags   = ["gke-${module.gke.name}"]
      allow = [{
        protocol = "tcp"
        ports    = ["15017"]
      }]
    }
  ]
}
