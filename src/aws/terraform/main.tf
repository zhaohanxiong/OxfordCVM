# define platform (when running with aws CLI)
provider "aws" {
    profile = "default"
    region = "us-east-1"
}

# s3 configuration
#   AWS free tier (as of 15-09-2022):
#   - 5GB standard storage
#   - 20,000 GET requests per month
#   - 2,000 PUT/COPY/POST/LIST requests per month
#   - 100 GB data transfer out each month
#resource "aws_s3_bucket" "s3_bucket_name" {
#    bucket = "cti-ukb-data"
#    tags = {
#        Name        = "cti-ukb-data"
#        Environment = "dev"
#    }
#}
#
#resource "aws_s3_bucket_acl" "s3_acl" {
#    bucket = aws_s3_bucket.s3_bucket_name.id
#    acl = "private"
#}
#
#resource "aws_s3_bucket_versioning" "s3_version" {
#    bucket = aws_s3_bucket.s3_bucket_name.id
#    versioning_configuration {
#        status = "Disabled"
#    }
#}
#
#resource "aws_s3_object" "s3_object" {
#    bucket = aws_s3_bucket.s3_bucket_name.id
#    key = "dvc"
#}
#
#resource "aws_s3_bucket_public_access_block" "example" {
#    bucket = aws_s3_bucket.s3_bucket_name.id
#    block_public_acls = false
#    block_public_policy = false
#    ignore_public_acls = false
#    restrict_public_buckets = false
#}

# RDS configuration
#   AWS free tier (as of 15-09-2022):
#   - 20 GB of General Purpose (SSD) DB Storage
#   - 20 GB of backup storage for your automated database backups and 
#     any user-initiated DB snapshots
#   - 750 hours of Single-AZ db.t2.micro/db.t3.micro/db.t4g.micro Instances 
#     for MySQL/MariaDB/PostgreSQL per month
#   - If running more than one instance, usage is aggregated across all instance
#   - 750 hours of RDS Single-AZ db.t2.micro Instance usage running SQL Server 
#     (running SQL Server Express Edition) per month
resource "aws_db_instance" "rds_postgresql_name" {
    allocated_storage = 10
    engine = "mysql"
    engine_version = "5.7"
    instance_class = "db.t3.micro"
    name = "mydb"
    username = "foo"
    password = "foobarbaz"
    parameter_group_name = "default.mysql5.7"
    skip_final_snapshot = true
}

# ECR configuration
#   AWS free tier (as of 15-09-2022):
#   - 500 MB per month of storage for private repositories
#   - 50 GB of free storage for public repositories
#   - No cost transferring data in to private or public repositories
#   - Anonymously (without using an AWS account) transfer 500 GB of data to the 
#     Internet from a public repository each month
#   - If you authenticate to Amazon ECR with an existing AWS account, you can  
#     transfer 5 TB of data to the Internet from a public repository each month
#   - Unlimited bandwidth at no cost when transferring data from a public repository 
#     to AWS compute resources in any AWS Region.


# EC2 configuration
#   AWS free tier (as of 15-09-2022):
#   - 750 hours of t2.micro instances (use t3.micro for regions where t2.micro is 
#     unavailable) per month

# ECS configuration
#   - always free and cost depends on usage of AWS compute resources

# Fargate configuration