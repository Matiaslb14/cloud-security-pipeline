terraform {
  backend "s3" {
    bucket         = "matiaslb14-tfstate-use1"   # <-- usa el nombre real que creaste
    key            = "cloud-security-pipeline/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    # dynamodb_table = "terraform-locks"         # si creaste la tabla
  }
}
