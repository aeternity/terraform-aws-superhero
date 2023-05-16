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
  
  env_mapping = {
    dev    = 0
    stg    = 0
    prd    = 1
  }

   only_in_production_mapping = {
    dev    = 1
    stg    = 0
    prd    = 1
  }

  only_in_production = local.only_in_production_mapping[terraform.workspace]
  
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
      statsd_secondary_private_ips         = "10.0.4.21"
      graffiti_redis_disk_size             = "50"
      backend_redis_disk_size              = "50"
      ipfs_disk_size                       = "50"
      rds_instance_class                   = "db.t2.small"
      superhero_rds_password               = random_string.superhero_rds_password.result
      dex_rds_password                     = random_string.dex_rds_password.result
      testnet_disk_size                    = "20"
      testnet_root_disk_size               = "20"
      testnet_instance_type                = "t2.small"
      cdn_aliases = "aescan.dev.aepps.com"
      cdn_domain_name = "dev-wgt7-traefik-ingress-3137535e34fdb198.elb.eu-central-1.amazonaws.com"
      cdn_origin_id = "dev-wgt7-traefik-ingress-3137535e34fdb198.elb.eu-central-1.amazonaws.com"
      cdn_target_origin_id = "dev-wgt7-traefik-ingress-3137535e34fdb198.elb.eu-central-1.amazonaws.com"
      cdn_acm_certificate_arn = "arn:aws:acm:us-east-1:106102538874:certificate/a04b71bf-79c5-409d-8de5-45c29d9d2bc5"
    }

    prd = {
      ipfs_secondary_private_ips           = "172.16.4.104"
      redis_backend_secondary_private_ips  = "172.16.1.111"
      redis_grafitti_secondary_private_ips = "172.16.1.101"
      graffiti_redis_disk_size             = "50"
      backend_redis_disk_size              = "50"
      ipfs_disk_size                       = "100"
      rds_instance_class                   = "db.m5.large"
      superhero_rds_password               = random_string.superhero_rds_password.result
      dex_rds_password                     = random_string.dex_rds_password.result
      testnet_disk_size                    = "200"
      testnet_root_disk_size               = "200"
      testnet_instance_type                = "m5a.large"
      statsd_secondary_private_ips         = "172.16.1.122"
      cdn_aliases = "aescan.prd.aepps.com"
      cdn_domain_name = "prd-0e9c-traefik-ingress-ee681509e4f99dc7.elb.eu-central-1.amazonaws.com"
      cdn_origin_id = "prd-0e9c-traefik-ingress-ee681509e4f99dc7.elb.eu-central-1.amazonaws.com"
      cdn_target_origin_id = "prd-0e9c-traefik-ingress-ee681509e4f99dc7.elb.eu-central-1.amazonaws.com"
      cdn_acm_certificate_arn = "arn:aws:acm:us-east-1:106102538874:certificate/3d041f97-8742-4cea-b58b-91e41fd23177"
    }

    stg = {
      ipfs_secondary_private_ips           = "192.168.4.104"
      redis_backend_secondary_private_ips  = "192.168.1.111"
      redis_grafitti_secondary_private_ips = "192.168.1.100"
      graffiti_redis_disk_size             = "50"
      backend_redis_disk_size              = "50"
      ipfs_disk_size                       = "50"
      rds_instance_class                   = "db.t2.small"
      superhero_rds_password               = random_string.superhero_rds_password.result
      dex_rds_password                     = random_string.dex_rds_password.result
      testnet_disk_size                    = "20"
      testnet_root_disk_size               = "20"
      testnet_instance_type                = "t2.nano"
    }
  }

  config = merge(lookup(local.env_config, terraform.workspace, {}))
}
