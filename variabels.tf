variable "postgres_passwd" {
  type = map(any)
}

variable "ipfs_secondary_private_ips" {
  default = {
    "dev" = "10.0.4.4"
    "stg" = "192.168.4.104"
  }
}

variable "redis_backend_secondary_private_ips" {
  default = {
    "dev" = "10.0.1.11"
    "stg" = "192.168.1.101"
  }
}

variable "redis_grafitti_secondary_private_ips" {
  default = {
    "dev" = "10.0.1.13"
    "stg" = "192.168.1.100"
  }
}
