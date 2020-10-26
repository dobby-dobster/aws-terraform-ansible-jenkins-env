# Set S3 backend for persisting TF state file remotely, 
# ensure bucket already exits
# and that AWS user being used by TF has read/write perms

# command to create bucket:
# aws s3api create-bucket --bucket <bucket name>

terraform {
  required_version = ">=0.12.0"
  required_providers {
    aws = {
      version = ">=3.0.0"
    }
  }
  backend "s3" {
    region  = "us-east-1"
    profile = "default"
    key     = "terraformstatefile"
    bucket  = "aws-terraform-ansible11"
  }
}