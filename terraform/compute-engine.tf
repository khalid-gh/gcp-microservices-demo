resource "google_compute_instance" "privoxy" {
  name                      = "privoxy"
  project                   = var.project_id
  machine_type              = "e2-micro"
  zone                      = "${var.region}-b"
  allow_stopping_for_update = true

  tags = ["privoxy"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-13"
      size  = 10
    }
    auto_delete       = true
    kms_key_self_link = module.kms.keys["privoxy-disk-key"]
  }

  network_interface {
    subnetwork = module.vpc.subnets["${var.region}/privoxy-subnet"].self_link
  }

  shielded_instance_config {
    enable_vtpm        = true
    enable_secure_boot = true
  }

  metadata = {
    enable-oslogin         = "TRUE"
    block-project-ssh-keys = "TRUE"
  }

  metadata_startup_script = <<-SCRIPT
    #!/bin/bash
    set -euxo pipefail

    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y privoxy ca-certificates curl

    cat > /etc/privoxy/config <<'EOF'
    confdir /etc/privoxy
    logdir /var/log/privoxy
    logfile logfile
    actionsfile user.action
    listen-address 0.0.0.0:8118
    permit-access 35.235.240.0/20
    enable-remote-toggle 0
    enable-remote-http-toggle 0
    enable-edit-actions 0
    enforce-blocks 1
    EOF

    cat > /etc/privoxy/user.action <<'EOF'
    {+block{Destination not permitted} +limit-connect{443}}
    /

    {-block}
    ${module.gke.endpoint}:443
    EOF

    privoxy --no-daemon --config-test /etc/privoxy/config
    systemctl enable privoxy
    systemctl restart privoxy
    systemctl is-active --quiet privoxy

    (
      workdir=$(mktemp -d)
      trap 'rm -f "$workdir/add-google-cloud-ops-agent-repo.sh"; rmdir "$workdir"' EXIT
      cd "$workdir"
      curl -fsSLO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
      bash add-google-cloud-ops-agent-repo.sh --also-install
    )
    systemctl is-active --quiet google-cloud-ops-agent
  SCRIPT

  service_account {
    email  = google_service_account.privoxy.email
    scopes = ["cloud-platform"]
  }
}
