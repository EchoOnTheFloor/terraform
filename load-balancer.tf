resource "google_compute_global_address" "lb_ip" {
  name = "lb-ip"
}

resource "google_compute_backend_service" "backend" {
  name          = "backend-service"
  protocol      = "HTTP"
  health_checks = [google_compute_health_check.http-check.id]
  backend {
    group = google_compute_instance_group_manager.igm.instance_group
  }
}

resource "google_compute_url_map" "url_map" {
  name            = "lb-url-map"
  default_service = google_compute_backend_service.backend.id
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.url_map.id
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "lb-forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.lb_ip.address
}