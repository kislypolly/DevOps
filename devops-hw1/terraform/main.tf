terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "ssh://student@111.88.162.110:22"
}

# Отдельная сеть
resource "docker_network" "nginx_network" {
  name = "hw1-terraform-net"
}

# Docker volume
resource "docker_volume" "nginx_volume" {
  name = "hw1-nginx-volume"
}

# Образ Nginx
resource "docker_image" "nginx" {
  name         = "nginx:stable-alpine"
  keep_locally = true
}

# Контейнер Nginx
resource "docker_container" "nginx" {
  name  = "hw1-terraform-nginx"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.nginx_network.name
  }

  volumes {
    volume_name    = docker_volume.nginx_volume.name
    container_path = "/usr/share/nginx/html"
  }

  ports {
    internal = 80
    external = 8081
    ip       = "127.0.0.1"
  }
}
