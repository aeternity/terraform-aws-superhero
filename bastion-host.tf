locals {
  bastion_name = terraform.workspace
  bastion_tags = merge({ "Name" : local.bastion_name }, local.standard_tags)
}


module "bastion" {
  source  = "umotif-public/bastion/aws"
  version = "~> 2.1.0"

  name_prefix    = local.bastion_name
  vpc_id         = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets = [data.terraform_remote_state.vpc.outputs.public_subnets[0]]

  hosted_zone_id = "Z8J0F7X8EN90Z"
  ssh_key_name   = "bastion"

  tags = local.bastion_tags
}
