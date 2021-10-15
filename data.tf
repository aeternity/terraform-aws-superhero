data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "aeternity-terraform-states"
    key    = "env://${terraform.workspace}/ae-apps.tfstate"
    region = "us-east-1"
  }
}
