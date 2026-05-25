terraform {
  backend "s3" {
    bucket  = "tf-state-bucket-sls"
    key     = "serverless-ecommerce/dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
