# terraform/backend.tf
terraform {
  backend "s3" {
    bucket = "matiaslb14-tfstate-ue1"                  # 👈 exacto como en S3
    key    = "cloud-security-pipeline/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    # dynamodb_table = "matiaslb14-terraform-locks"    # opcional si creas la tabla
  }
}
