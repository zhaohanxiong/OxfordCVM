# finds folder aws and retrieves IAM
provider "aws" {
    profile = "default"
    region = "us-east-1"

}

# create s3 bucket
resource "aws_s3_bucket" "s3_name" {
    bucket = "cti-ukb-data"
    acl = "private"
}