terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = "AQ*****6o"
  cloud_id  = "b1***fh"
  folder_id = "b1**lr"
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "main-network" {
  name = "main-network"
}

resource "yandex_vpc_subnet" "main-subnet" {
  name           = "main-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_instance" "ubuntu_vm" {
  name = "irc-server"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd82re2tpfl4chaupeuf"
      size     = 5
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.main-subnet.id
    nat            = true
    ip_address     = "192.168.10.10"
    nat_ip_address = "51.250.64.147"
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/irc_server_key.pub")}"
    serial-port-enable : 1
  }
}

output "internal_ip_address_ubuntu_vm" {
  value = yandex_compute_instance.ubuntu_vm.network_interface.0.ip_address
}

output "external_ip_address_ubuntu_vm" {
  value = yandex_compute_instance.ubuntu_vm.network_interface.0.nat_ip_address
}
