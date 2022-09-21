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

# allow VPC to access DB instance
resource "aws_db_subnet_group" "db_subnet_group" {
    subnet_ids  = [aws_subnet.pub_subnet1.id, aws_subnet.pub_subnet2.id]
}

resource "aws_db_instance" "rds_postgresql_name" {
    engine                              = "postgres"
    engine_version                      = "13.7"
    instance_class                      = "db.t2.micro"
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
