variable "project_id" {
  type        = string
  description = "GCP project ID to deploy resources into"
}

variable "region" {
  type        = string
  description = "GCP region to deploy resources into"
  default     = "europe-west2"
}

variable "services" {
  type        = set(string)
  description = "Google APIs to enable"
  default = [
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iap.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
  validation {
    condition     = alltrue(flatten([[for service in var.services : service != "" && endswith(service, "googleapis.com") ? true : false]]))
    error_message = "Service must end with .googleapis.com"
  }
}

variable "kubernetes_proxy_url" {
  type        = string
  description = "Local IAP tunnel URL used only for Kubernetes and Helm API requests"
  default     = "http://127.0.0.1:8118"
}

variable "master_authorized_networks" {
  type        = list(object({ cidr_block = string, display_name = string }))
  description = "Additional master authorized networks. The Privoxy subnet and GKE node IPs are always authorized"
  default = [
    { cidr_block = "10.0.0.0/18", display_name = "gke-demo-subnet" }
  ]
}
