locals {
  testnet_name = "testnet-${local.env_human}"
  testnet_tags = merge({ "Name" : local.testnet_name, "ebs-backup" : "true" }, local.standard_tags)
}

module "testnet-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.4.0"

  name        = local.testnet_name
  description = "Security group for testnet"
  vpc_id      = data.terraform_remote_state.ae_apps.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 3013
      to_port     = 3013
      protocol    = "tcp"
      description = "testnet ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 3113
      to_port     = 3113
      protocol    = "tcp"
      description = "testnet ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 3014
      to_port     = 3014
      protocol    = "tcp"
      description = "testnet ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "https port"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  ingress_cidr_blocks = [data.terraform_remote_state.ae_apps.outputs.vpc_cidr_block]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]
  tags                = local.testnet_tags
}

module "testnet" {

  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.2.0"

  name                   = local.testnet_name
  key_name               = "bastion"
  instance_type          = local.config.testnet_instance_type #"m5.4xlarge"
  ami                    = "ami-02058f44341e7f54e"
  subnet_id              = data.terraform_remote_state.ae_apps.outputs.public_subnets[0]
  tags                   = local.testnet_tags
  vpc_security_group_ids = [module.testnet-sg.security_group_id]
  enable_volume_tags     = false
  root_block_device = [{
    volume_size = local.config.testnet_root_disk_size
  }]
}

resource "aws_volume_attachment" "testnet" {

  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.testnet.id
  instance_id = module.testnet.id
}

resource "aws_ebs_volume" "testnet" {

  availability_zone = data.aws_availability_zones.available.names[0]
  # size should be configured per requirements for each environment, we have to choose and disk type
  size = local.config.testnet_disk_size
  type = "gp3"
  tags = local.testnet_tags
}

resource "aws_route53_record" "testnet" {

  zone_id = "Z8J0F7X8EN90Z"
  name    = "testnet.${local.env_human}.aepps.com"
  type    = "A"
  ttl     = "300"
  records = [module.testnet.public_ip]
}
