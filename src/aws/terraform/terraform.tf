# store the state of the terraform project in AWS S3
# comment out to store locally
# terraform {
#     backend "s3" {
#         bucket = "cti-ukb-tf-state"
#         key    = "state.tfstate"
#     }
# }

# define platform (when running with aws CLI)
provider "aws" {
    profile = "default"
    region  = "us-east-1"
}

data "aws_availability_zones" "available_zones" {
    state = "available"
}

# configure virtual private cloud to create isolated virtual network 
resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/24"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name = "Terraform VPC"
    }
}

# configure communication between instances in VPC and internet
resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.vpc.id
}

# configure and create sub network
resource "aws_subnet" "pub_subnet1" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.0.0.0/25"
    availability_zone = "us-east-1a"
}

resource "aws_subnet" "pub_subnet2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.0.128/25"
  availability_zone = "us-east-1b"
}

# configure where network traffic from subnets are directed
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }
}

resource "aws_route_table_association" "route_table_association" {
    subnet_id      = aws_subnet.pub_subnet1.id
    route_table_id = aws_route_table.public.id
}

# configure security groups to restrict access
resource "aws_security_group" "rds_sg" {
    vpc_id = aws_vpc.vpc.id

    ingress {
        protocol        = "tcp"
        from_port       = 5432
        to_port         = 5432
        cidr_blocks     = ["0.0.0.0/0"]
        security_groups = [aws_security_group.ecs_sg.id]
    }

    egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "ecs_sg" {
    vpc_id = aws_vpc.vpc.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

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

# allow VPC to access DB instance in the defined subnets
resource "aws_db_subnet_group" "db_subnet_group" {
    subnet_ids  = [aws_subnet.pub_subnet1.id, aws_subnet.pub_subnet2.id]
}

# define RDS instance
resource "aws_db_instance" "rds_postgresql_name" {
    engine                              = "postgres"
    engine_version                      = "13.7"
    instance_class                      = "db.t3.micro"
    identifier                          = "ukb-db"
    db_name                             = "ukb_postgres_db"
    username                            = "zhaohanxiong_rds_username"
    password                            = "zhaohanxiong_rds_password"
    publicly_accessible                 = false
    skip_final_snapshot                 = true
    multi_az                            = true
    allocated_storage                   = 10
    port                                = 5432
    iam_database_authentication_enabled = false
    db_subnet_group_name                = aws_db_subnet_group.db_subnet_group.id
    vpc_security_group_ids              = [aws_security_group.rds_sg.id, aws_security_group.ecs_sg.id]
    final_snapshot_identifier           = "ukb-db-final"
}

# output various parameters associated with the RDS instance
output "postgresql_endpoint" {
    value = aws_db_instance.rds_postgresql_name.endpoint
}

# S3 configuration
#   AWS free tier (as of 15-09-2022):
#   - 5GB standard storage
#   - 20,000 GET requests per month
#   - 2,000 PUT/COPY/POST/LIST requests per month
#   - 100 GB data transfer out each month

# create an s3 bucket, bucket name needs to be unique globally
resource "aws_s3_bucket" "s3_bucket_name" {
    bucket = "cti-ukb-data"
    tags = {
        Name        = "cti-ukb-data"
        Environment = "dev"
    }
}

# add sub direcotry to s3 bucket
resource "aws_s3_object" "s3_object" {
    bucket = aws_s3_bucket.s3_bucket_name.id
    key    = "dvc"
}

# configure access
resource "aws_s3_bucket_acl" "s3_acl" {
    bucket = aws_s3_bucket.s3_bucket_name.id
    acl    = "private"
}

# configure bucket versioning
resource "aws_s3_bucket_versioning" "s3_version" {
    bucket = aws_s3_bucket.s3_bucket_name.id
    versioning_configuration {
        status = "Disabled"
    }
}

# configure access
resource "aws_s3_bucket_public_access_block" "s3_access" {
    bucket                  = aws_s3_bucket.s3_bucket_name.id
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
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

# create public elastic container repo
resource "aws_ecrpublic_repository" "ecr_name1" {
    repository_name = "cti-pred"
}

# attach policy to public repo
resource "aws_ecrpublic_repository_policy" "ecr_name1" {
    repository_name = aws_ecrpublic_repository.ecr_name.repository_name
    policy = <<EOF
        {
            "Version": "2008-10-17",
            "Statement": [
                {
                    "Sid": "new policy",
                    "Effect": "Allow",
                    "Principal": "*",
                    "Action": [
                        "ecr:GetDownloadUrlForLayer",
                        "ecr:BatchGetImage",
                        "ecr:BatchCheckLayerAvailability",
                        "ecr:PutImage",
                        "ecr:InitiateLayerUpload",
                        "ecr:UploadLayerPart",
                        "ecr:CompleteLayerUpload",
                        "ecr:DescribeRepositories",
                        "ecr:GetRepositoryPolicy",
                        "ecr:ListImages",
                        "ecr:DeleteRepository",
                        "ecr:BatchDeleteImage",
                        "ecr:SetRepositoryPolicy",
                        "ecr:DeleteRepositoryPolicy"
                    ]
                }
            ]
        }
        EOF
}

# add private repo
resource "aws_ecr_repository" "ecr_name2" {
    name                 = "cti-pred"
    image_tag_mutability = "MUTABLE"
    image_scanning_configuration {
        scan_on_push = true
    }
}

# output various parameters associated with ECR
output "ecr_repository_worker_endpoint" {
    value = aws_ecrpublic_repository.ecr_name1.repository_uri
}

output "ecr_repository_worker_endpoint" {
    value = aws_ecr_repository.ecr_name2.repository_url
}

