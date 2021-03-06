locals {
  backend_redis_name = "superhero-backend-redis-${local.env_human}"
  backend_redis_tags = merge({ "Name" : local.backend_redis_name, "ebs-backup" : "true" }, local.standard_tags)
}

module "superhero-backend-redis-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.4.0"

  name        = local.backend_redis_name
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

  tags = local.backend_redis_tags
}

module "superhero-backend-redis" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.2.0"

  name                   = local.backend_redis_name
  key_name               = "bastion"
  instance_type          = "t2.medium"
  ami                    = "ami-049dba36e59403eff"
  subnet_id              = data.terraform_remote_state.ae_apps.outputs.private_subnets[0]
  secondary_private_ips  = [local.config.redis_backend_secondary_private_ips]
  tags                   = local.backend_redis_tags
  vpc_security_group_ids = [module.superhero-backend-redis-sg.security_group_id]
  enable_volume_tags = false
}

resource "aws_volume_attachment" "superhero-backend-redis" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.superhero-backend-redis.id
  instance_id = module.superhero-backend-redis.id
}

resource "aws_ebs_volume" "superhero-backend-redis" {
  availability_zone = data.aws_availability_zones.available.names[0]
  # size should be configured per requirements for each environment, we have to choose and disk type
  size = local.config.backend_redis_disk_size
  type = "gp3"
  tags = local.backend_redis_tags
}
