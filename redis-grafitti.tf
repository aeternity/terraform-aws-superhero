locals {
  graffiti_redis_name = "graffiti-redis-${local.env_human}"
  graffiti_redis_tags = merge({ "Name" : local.graffiti_redis_name, "ebs-backup" : "true" } , local.standard_tags)
}

module "graffiti-redis-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.4.0"

  name        = local.graffiti_redis_name
  description = "Security group for Redis"
  vpc_id      = data.terraform_remote_state.ae_apps.outputs.vpc_id

  ingress_cidr_blocks = [data.terraform_remote_state.ae_apps.outputs.vpc_cidr_block]
  ingress_with_cidr_blocks = [
    {
      from_port   = 9121
      to_port     = 9121
      protocol    = "tcp"
      description = "Redis exporter ports"
      cidr_blocks = data.terraform_remote_state.ae_apps.outputs.vpc_cidr_block
    },
    {
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      description = "Node exporter ports"
      cidr_blocks = data.terraform_remote_state.ae_apps.outputs.vpc_cidr_block
    },
  ]
  ingress_rules = ["redis-tcp", "ssh-tcp"]
  egress_rules  = ["all-all"]

  tags = local.graffiti_redis_tags
}

module "graffiti-redis" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.2.0"

  name                   = local.graffiti_redis_name
  key_name               = "bastion"
  instance_type          = "t2.medium"
  ami                    = "ami-049dba36e59403eff"
  subnet_id              = data.terraform_remote_state.ae_apps.outputs.private_subnets[0]
  secondary_private_ips  = [local.config.redis_grafitti_secondary_private_ips]
  tags                   = local.graffiti_redis_tags
  vpc_security_group_ids = [module.graffiti-redis-sg.security_group_id]
  enable_volume_tags = false
}

resource "aws_volume_attachment" "graffiti-redis" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.graffiti-redis.id
  instance_id = module.graffiti-redis.id
}

resource "aws_ebs_volume" "graffiti-redis" {
  availability_zone = data.aws_availability_zones.available.names[0]
  # size should be configured per requirements for each environment, we have to choose and disk type
  size = local.config.graffiti_redis_disk_size
  type = "gp3"
  tags = local.graffiti_redis_tags
}

resource "aws_route53_record" "redis-graffiti" {
  zone_id = "Z8J0F7X8EN90Z"
  name    = "redis-graffiti.${local.env_human}.aepps.com"
  type    = "A"
  ttl     = "300"
  records = [local.config.redis_backend_secondary_private_ips]
}
