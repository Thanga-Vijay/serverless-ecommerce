terraform {
  backend "s3" {
    bucket  = "tf-state-bucket-sls"
    key     = "serverless-ecommerce/prod/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
