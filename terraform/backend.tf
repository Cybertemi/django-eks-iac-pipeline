terraform {
  backend "s3" {
    bucket         = "primechoice-terraform-state-12345"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}