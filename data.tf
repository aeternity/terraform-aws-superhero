data "terraform_remote_state" "ae_apps" {
  backend = "s3"

  config = {
    bucket = "aeternity-terraform-states"
    key    = "env://${local.env_human}/ae-apps.tfstate"
    region = "us-east-1"
  }
}
