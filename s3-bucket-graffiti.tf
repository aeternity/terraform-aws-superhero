module "s3_bucket_graffiti" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "aeternity-superhero-graffiti-${local.env_human}"
  acl    = "private"

  versioning = {
    enabled = false
  }
}

module "graffiti_s3_user" {
  source = "cloudposse/iam-s3-user/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version = "1.0.0"
  namespace    = "aeternity"
  stage        = "${local.env_human}"
  name         = "graffiti-backend-s3"
  s3_actions   = ["s3:GetObject", "s3:PutObject"]
  s3_resources = ["${module.s3_bucket_graffiti.s3_bucket_arn}/*"]
}
