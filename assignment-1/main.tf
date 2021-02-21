provider "aws" {
  region     = "us-east-1"
}

resource "aws_s3_bucket" "my-s3-bucket" {
  bucket = "krishna-test-bucket-xyz"
   tags = {
     "Name" = "example1-bucket"
     "product" = "terraform-example1"
   }
   
}