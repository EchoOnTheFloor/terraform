resource "google_service_account" "default" {
  account_id   = "sa-compute-tp"
  display_name = "Service Account TP"
}

resource "google_compute_instance_template" "tpl" {
  name         = "template-tp"
  machine_type = "f1-micro"

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
  }

  metadata_startup_script = file("scripts/startup.sh")

  service_account {
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_health_check" "http-check" {
  name = "http-check"
  http_health_check { port = 80 }
}

resource "google_compute_instance_group_manager" "igm" {
  name               = "igm-tp"
  base_instance_name = "vm-tp"
  target_size        = 1

  version {
    instance_template = google_compute_instance_template.tpl.id
  }

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_autoscaler" "autoscaler" {
  name   = "autoscaler"
  target = google_compute_instance_group_manager.igm.id
  autoscaling_policy {
    max_replicas = 3
    min_replicas = 1
    cpu_utilization { target = 0.6 }
  }
}