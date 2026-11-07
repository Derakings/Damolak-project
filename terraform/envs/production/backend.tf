terraform {
  backend "s3" {
    bucket       = "devops-challenge-tfstate-553737064319"
    key          = "devops-challenge/prod/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}