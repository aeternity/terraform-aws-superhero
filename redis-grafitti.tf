locals {
  graffiti_redis_name = "graffiti-redis-${terraform.workspace}"
  graffiti_redis_tags = merge({ "Name" : local.graffiti_redis_name }, local.standard_tags)
}

module "graffiti-redis-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.4.0"

  name        = local.graffiti_redis_name
  description = "Security group for Redis"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  ingress_with_cidr_blocks = [
    {
      from_port   = 9121
      to_port     = 9121
      protocol    = "tcp"
      description = "Redis exporter ports"
      cidr_blocks = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
    },
    {
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      description = "Node exporter ports"
      cidr_blocks = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
    },
  ]
  ingress_rules       = ["redis-tcp", "ssh-tcp"]
  egress_rules        = ["all-all"]

  tags = local.graffiti_redis_tags
}

module "graffiti-redis" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.2.0"

  name                   = local.graffiti_redis_name
  key_name               = "bastion"
  instance_type          = "t2.medium"
  ami                    = "ami-049dba36e59403eff"
  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnets[0]
  secondary_private_ips  = [var.redis_grafitti_secondary_private_ips[terraform.workspace]]
  tags                   = local.graffiti_redis_tags
  vpc_security_group_ids = [module.graffiti-redis-sg.security_group_id]
}

resource "aws_volume_attachment" "graffiti-redis" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.graffiti-redis.id
  instance_id = module.graffiti-redis.id
}

resource "aws_ebs_volume" "graffiti-redis" {
  availability_zone = data.aws_availability_zones.available.names[0]
  # size should be configured per requirements for each environment, we have to choose and disk type
  size = var.graffiti_redis_disk_size[terraform.workspace]
  type = "gp3"
  tags = local.graffiti_redis_tags
}
