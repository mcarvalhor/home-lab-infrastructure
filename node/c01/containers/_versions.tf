terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.9.0"
    }
  }
}
