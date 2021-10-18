data "aws_availability_zones" "available" {}

locals {
  # use this variable as prefix for all resource names. This avoids conflicts with globally unique resources (all resources with a hostname)
  env       = "${terraform.workspace}"
  env_human = terraform.workspace

  standard_tags = {
    "env"         = local.env
    "project"     = "apps"
    "github-repo" = "terraform-aws-superhero"
    "github-org"  = "aeternity"
  }
}
