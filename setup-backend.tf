# ============================================
# This file is used to create S3 bucket and DynamoDB table
# Run BEFORE running terraform init in the eks/ directory
# ============================================
# 
# Usage:
# 1. terraform init
# 2. terraform plan
# 3. terraform apply
# 4. Then go to eks/ directory and run terraform init
# ============================================

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

# S3 bucket cho Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "KhanhhocdevopsS3bucket"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Enable versioning cho S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption cho S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state_pab" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets  = true
}

# DynamoDB table cho state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Output to confirm
output "s3_bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "Created S3 bucket name"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_state_lock.name
  description = "Created DynamoDB table name"
}

