module "s3_bucket_graffiti" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "aeternity-superhero-graffiti"
  acl    = "private"

  versioning = {
    enabled = false
  }

}
