variable "postgres_passwd" {
  type = map(any)
}

variable "opensearch_master_user_password" {
  type = map(any)
}

variable "ipfs_secondary_private_ips" {
  default = {
    "dev" = "10.0.4.4"
    "stg" = "192.168.4.104"
    "prd" = "172.16.4.104"
  }
}

variable "redis_backend_secondary_private_ips" {
  default = {
    "dev" = "10.0.1.11"
    "stg" = "192.168.1.111"
    "prd" = "172.16.1.111"
  }
}

variable "redis_grafitti_secondary_private_ips" {
  default = {
    "dev" = "10.0.1.13"
    "stg" = "192.168.1.100"
    "prd" = "172.16.1.101"
  }
}

variable "graffiti_redis_disk_size" {
  default = {
    "dev" = "50"
    "stg" = "50"
    "prd" = "50"
  }
}

variable "backend_redis_disk_size" {
  default = {
    "dev" = "50"
    "stg" = "50"
    "prd" = "50"
  }
}

variable "ipfs_disk_size" {
  default = {
    "dev" = "50"
    "stg" = "50"
    "prd" = "100"
  }
}

variable "rds_instance_class" {
  default = {
    "dev" = "db.t2.small"
    "stg" = "db.t2.small"
    "prd" = "db.m5.large"
  }
}

variable "warm_instance_enabled" {
  default = {
    "dev" = "false"
  }
}

variable "master_instance_count" {
  default = {
    "dev" = 1
  }
}

variable "master_instance_enabled" {
  default = {
    "dev" = "false"
  }
}

variable "hot_instance_count" {
  default = {
    "dev" = 1
  }
}

variable "availability_zones" {
  default = {
    "dev" = 1
  }
}
