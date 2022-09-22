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
    cidr_block = "172.31.0.0/16"
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
    cidr_block = "172.31.0.0/20"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "pub_subnet2" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "172.31.16.0/20"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
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
    name = "rds_sg"
    vpc_id = aws_vpc.vpc.id
    ingress {
        protocol        = "tcp"
        from_port       = 5432
        to_port         = 5432
        cidr_blocks     = ["0.0.0.0/0"]
    }
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}
