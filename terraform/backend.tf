terraform {
  backend "s3" {
    bucket         = "tf-state-<TU-BUCKET-UNICO>"
    key            = "cloud-security-pipeline/infra.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
