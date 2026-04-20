resource "google_storage_bucket" "bucket" {
  name     = "${var.project_id}-tp-bucket"
  location = var.region
}