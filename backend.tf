terraform {
  backend "s3" {
    bucket       = "prav-tf-test-buck"
    key          = "portfolio-deploy-terraform/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}