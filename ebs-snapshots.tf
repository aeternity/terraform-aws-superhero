module "ebs-backup-policy" {
  source = "github.com/fpco/terraform-aws-foundation//modules/dlm-lifecycle-policy"

  name_prefix = "superhero-${local.env_human}"
  description = "DLM lifecycle policy"
  ebs_target_tags = {
    "ebs-backup" = "true"
  }
  policy_name        = "One week of daily snapshots"
  policy_interval    = 24
  policy_times       = ["23:45"]
  policy_copy_tags   = false
  policy_retain_rule = 14
  policy_tags_to_add = tomap({ "Name" = "superhero-${local.env_human}-dlm" })
  resource_type      = ["VOLUME"]
}
