data "aws_availability_zones" "available" {}

resource "random_string" "superhero_rds_password" {
  length  = 12
  special = true
  upper   = true
}

resource "random_string" "dex_rds_password" {
  length  = 12
  special = false
  upper   = true
}

locals {
  # use this variable as prefix for all resource names. This avoids conflicts with globally unique resources (all resources with a hostname)
  env       = terraform.workspace
  env_human = terraform.workspace

  standard_tags = {
    "env"         = local.env
    "project"     = "apps"
    "github-repo" = "terraform-aws-superhero"
    "github-org"  = "aeternity"
  }
  
  env_config = {
    dev = {
      ipfs_secondary_private_ips           = "10.0.4.4"
      redis_backend_secondary_private_ips  = "10.0.1.11"
      redis_grafitti_secondary_private_ips = "10.0.1.13"
      graffiti_redis_disk_size             = "50"
      backend_redis_disk_size              = "50"
      ipfs_disk_size                       = "50"
      rds_instance_class                   = "db.t2.small"
      superhero_rds_password = random_string.superhero_rds_password.result
      dex_rds_password = random_string.dex_rds_password.result
    }

    prd = {
      ipfs_secondary_private_ips           = "172.16.4.104"
      redis_backend_secondary_private_ips  = "172.16.1.111"
      redis_grafitti_secondary_private_ips = "172.16.1.101"
      graffiti_redis_disk_size             = "50"
      backend_redis_disk_size              = "50"
      ipfs_disk_size                       = "100"
      rds_instance_class                   = "db.m5.large"
      superhero_rds_password = random_string.superhero_rds_password.result
      dex_rds_password = random_string.dex_rds_password.result
    }

    stg = {
      ipfs_secondary_private_ips           = "192.168.4.104"
      redis_backend_secondary_private_ips  = "192.168.1.111"
      redis_grafitti_secondary_private_ips = "192.168.1.100"
      graffiti_redis_disk_size             = "50"
      backend_redis_disk_size              = "50"
      ipfs_disk_size                       = "50"
      rds_instance_class                   = "db.t2.small"
      superhero_rds_password = random_string.superhero_rds_password.result
      dex_rds_password = random_string.dex_rds_password.result
    }
  }

  config = merge(lookup(local.env_config, terraform.workspace, {}))
}
