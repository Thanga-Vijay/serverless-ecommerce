terraform {
  backend "s3" {
    bucket  = "tf-state-bucket-sls"
    key     = "terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}
