provider "google" {
  project = var.project_id
  region  = var.region
  zone    = "${var.region}-b"
}

# 1. APIの有効化
resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudresourcemanager" {
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

# 2. 完全に独立したカスタムVPCネットワーク
resource "google_compute_network" "vpc_network" {
  name                    = "openclaw-vpc"
  auto_create_subnetworks = false

  depends_on = [google_project_service.compute]
}

resource "google_compute_subnetwork" "subnet" {
  name          = "openclaw-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# 2. アウトバウンド用：Cloud Router & Cloud NAT
resource "google_compute_router" "router" {
  name    = "openclaw-router"
  network = google_compute_network.vpc_network.id
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "openclaw-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# 3. インバウンド用：ファイアウォール（IAP経由のSSHのみ許可）
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-iap-ssh"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"] # IAPのIP帯域
}

# 4. VMインスタンス（外部IPなし）
resource "google_compute_instance" "vm_instance" {
  name         = "openclaw-vm"
  # e2-micro (1GB) だと openclaw gateway がメモリ不足でクラッシュするため e2-small 以上が必要
  machine_type             = "e2-small"
  allow_stopping_for_update = true
  zone         = "${var.region}-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet.id
    # access_config ブロックを書かないことで外部IPを付与しない
  }

  metadata = {
    startup-script = file("${path.module}/script/setup.sh")
  }
}
