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
  ingress_rules       = ["redis-tcp"]
  egress_rules        = ["all-all"]

  tags = local.graffiti_redis_tags
}

module "graffiti-redis" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.2.0"

  name                   = local.graffiti_redis_name
  key_name               = "temp"
  instance_type          = "t2.medium"
  ami                    = "ami-049dba36e59403eff"
  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnets[0]
  secondary_private_ips  = ["192.168.1.100"]
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
  size = 10
  type = "gp3"
  tags = local.graffiti_redis_tags
}
