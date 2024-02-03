# store the terraform state file in s3
terraform {
  backend "s3" {
    bucket    = "lordcarter-terraform-remote-statefile"
    key       = "lord-payne-website.tfstate"
    region    = "us-east-1"
    profile   = "terraform-user"
    # version = "4.55.0"
  }
 
}

