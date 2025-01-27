provider "google" {
  project     = var.project_name
  zone        = var.zone
  credentials = var.key_file_path
  region      = var.scanner_region
}
