locals {
  redis_name       = "superhero-backend-redis"
  redis_tags = merge({ "Name" : local.redis_name }, local.standard_tags)
}

module "superhero-backend-redis-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.4.0"

  name        = local.redis_name
  description = "Security group for Redis"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/16"]
  ingress_rules       = ["redis-tcp"]
  egress_rules        = ["all-all"]

  tags = local.redis_tags
}

module "superhero-backend-redis" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.2.0"

  name                  = local.redis_name
  key_name              = "temp"
  instance_type         = "t2.medium"
  ami                   = "ami-049dba36e59403eff"
  subnet_id             = data.terraform_remote_state.vpc.outputs.private_subnets[0]
  secondary_private_ips = ["10.0.1.11"]
  tags                  = local.redis_tags
}

resource "aws_volume_attachment" "superhero-backend-redis" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.superhero-backend-redis.id
  instance_id = module.superhero-backend-redis.id
}

resource "aws_ebs_volume" "superhero-backend-redis" {
  availability_zone = data.aws_availability_zones.available.names[0]
  # size should be configured per requirements for each environment, we have to choose and disk type
  size = 10
  type = "gp3"
  tags = local.redis_tags
}
