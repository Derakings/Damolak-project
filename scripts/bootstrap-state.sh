#!/usr/bin/env bash
# One-time setup: creates the S3 bucket that stores Terraform state.
# Usage: AWS_PROFILE=personal-challenge ./scripts/bootstrap-state.sh eu-west-1
set -euo pipefail

REGION="eu-west-1"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BUCKET="devops-challenge-tfstate-${ACCOUNT_ID}"

echo "Using AWS account: ${ACCOUNT_ID}"
read -r -p "Is this your PERSONAL account? (yes/no) " ANSWER
[ "$ANSWER" = "yes" ] || { echo "Aborting."; exit 1; }

if [ "$REGION" = "us-east-1" ]; then
  aws s3api create-bucket --bucket "$BUCKET" --region "$REGION"
else
  aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"
fi

aws s3api put-bucket-versioning --bucket "$BUCKET" --versioning-configuration Status=Enabled
aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "Done. Put this bucket name in terraform/envs/production/backend.tf: ${BUCKET}"
