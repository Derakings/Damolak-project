provider "aws" {
  region  = var.region
  profile = var.aws_profile # null in CI (Jenkins uses its own credentials)

  allowed_account_ids = [var.aws_account_id]

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
