output "load_balancer_ip" {
  value = google_compute_global_address.lb_ip.address
}

output "db_instance_ip" {
  value = google_sql_database_instance.instance.private_ip_address
}