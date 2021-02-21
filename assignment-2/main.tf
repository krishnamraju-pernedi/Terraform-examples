terraform {
  required_providers {
    docker = {
      source = "terraform-providers/docker"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx_rs_name" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx_container" {
  image = docker_image.nginx_rs_name.latest
  name  = "tutorial"
  ports {
    internal = 80
    external = 8000
  }
}
