provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

module "staging_server" {
  source = "../common"

  elb_port      = 80
  ec2_image_id  = "ami-830c94e3"
  instance_type = "t2.mico"
  min_size      = 1
  max_size      = 2
  elb_name      = "forgedm-test"
}