terraform {
  backend "s3" {
    bucket         = "eks-terraform-state-prod"
    key            = "eks/prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
