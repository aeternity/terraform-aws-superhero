locals {
  ipfs_name = "ipfs-${terraform.workspace}"
  ipfs_tags = merge({ "Name" : local.ipfs_name }, local.standard_tags)
}

module "ipfs-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.4.0"

  name        = local.ipfs_name
  description = "Security group for Ipfs"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 4001
      to_port     = 4001
      protocol    = "tcp"
      description = "Ipfs ports"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_rules = ["all-all"]

  tags = local.ipfs_tags
}

module "ipfs" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.2.0"

  name                   = local.ipfs_name
  key_name               = "temp"
  instance_type          = "t2.medium"
  ami                    = "ami-0eda1419e30a5a080"
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnets[0]
  secondary_private_ips  = [var.ipfs_secondary_private_ips[terraform.workspace]]
  tags                   = local.ipfs_tags
  vpc_security_group_ids = [module.ipfs-sg.security_group_id]
}

resource "aws_volume_attachment" "ipfs" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ipfs.id
  instance_id = module.ipfs.id
}

resource "aws_ebs_volume" "ipfs" {
  availability_zone = data.aws_availability_zones.available.names[0]
  # size should be configured per requirements for each environment, we have to choose and disk type
  size = 50
  type = "gp3"
  tags = local.ipfs_tags
}

resource "aws_route53_record" "ipfs" {
  zone_id = "Z8J0F7X8EN90Z"
  name    = "ipfs.${terraform.workspace}.aepps.com"
  type    = "A"
  ttl     = "300"
  records = [module.ipfs.public_ip]
}
