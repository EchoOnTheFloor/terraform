# VPC & Subnet
resource "google_compute_network" "vpc" {
  name                    = "main-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "main-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc.id
}

# Cloud NAT (pour que les instances privées accèdent au web)
resource "google_compute_router" "router" {
  name    = "router"
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name   = "nat"
  router = google_compute_router.router.name
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Firewalls
resource "google_compute_firewall" "ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name
  allow { protocol = "tcp"; ports = ["22"] }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "http" {
  name    = "allow-http"
  network = google_compute_network.vpc.name
  allow { protocol = "tcp"; ports = ["80"] }
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"] # IP du Load Balancer Google
}

# Private IP pour Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "google-managed-services-vpc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}