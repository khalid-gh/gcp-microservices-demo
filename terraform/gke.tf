module "gke" {
  source                     = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/private-cluster?ref=a19597ac18ad833d224448e2954df93095b8ce9d" # v47.0.0
  project_id                 = var.project_id
  name                       = "demo-cluster"
  regional                   = false
  zones                      = ["${var.region}-b"]
  network                    = module.vpc.network_name
  subnetwork                 = "gke-demo-subnet"
  ip_range_pods              = "gke-demo-subnet-pods"
  ip_range_services          = "gke-demo-subnet-services"
  http_load_balancing        = false
  remove_default_node_pool   = true
  horizontal_pod_autoscaling = true
  enable_private_nodes       = true
  enable_private_endpoint    = true
  master_authorized_networks = concat(var.master_authorized_networks, [
    {
      cidr_block   = module.vpc.subnets["${var.region}/privoxy-subnet"].ip_cidr_range
      display_name = "privoxy-subnet"
    }
  ])

  node_pools = [
    {
      name         = "default-node-pool"
      machine_type = "e2-standard-2"
      spot         = true
      min_count    = 1
      max_count    = 3
      disk_size_gb = 30
      disk_type    = "pd-standard"
      auto_repair  = true
      auto_upgrade = true
    }
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
