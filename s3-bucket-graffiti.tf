module "s3_bucket_graffiti" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "aeternity-superhero-graffiti-${local.env_human}"
  acl    = "private"

  versioning = {
    enabled = false
  }
}
