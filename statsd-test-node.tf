locals {
  statsd_name = "statsd-${local.env_human}"
}

module "statsd-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.4.0"

  name        = local.statsd_name
  description = "Security group for statsd"
  vpc_id      = data.terraform_remote_state.ae_apps.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 9102
      to_port     = 9102
      protocol    = "tcp"
      description = "statsd ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8125
      to_port     = 8125
      protocol    = "tcp"
      description = "statsd ports"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  ingress_cidr_blocks = [data.terraform_remote_state.ae_apps.outputs.vpc_cidr_block]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]
  tags                = local.standard_tags
}

module "statsd" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.2.0"

  name                   = local.statsd_name
  key_name               = "bastion"
  instance_type          = "t2.small"
  ami                    = "ami-0eda1419e30a5a080"
  subnet_id              = data.terraform_remote_state.ae_apps.outputs.public_subnets[0]
  secondary_private_ips  = [local.config.statsd_secondary_private_ips]
  tags                   = local.standard_tags
  vpc_security_group_ids = [module.statsd-sg.security_group_id]
  enable_volume_tags = false
}

resource "aws_route53_record" "statsd" {
  zone_id = "Z8J0F7X8EN90Z"
  name    = "statsd.${local.env_human}.aepps.com"
  type    = "A"
  ttl     = "300"
  records = [module.statsd.public_ip]
}
