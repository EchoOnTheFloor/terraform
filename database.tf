resource "google_sql_database_instance" "instance" {
  name             = "db-instance-tp"
  database_version = "POSTGRES_14"
  depends_on       = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }
  }
}

resource "google_sql_database" "database" {
  name     = "tp-db"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "user" {
  name     = "admin"
  instance = google_sql_database_instance.instance.name
  password = "password123"
}