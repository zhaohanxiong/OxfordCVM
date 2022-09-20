# store the state of the terraform project in AWS S3
terraform {
    backend "s3" {
        bucket = "cti-ukb-data"
        key    = "state.tfstate"
    }
}

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
resource "aws_subnet" "pub_subnet" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.0.0.16/28"
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
    subnet_id      = aws_subnet.pub_subnet.id
    route_table_id = aws_route_table.public.id
}

# configure security groups to restrict access
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

# EC2 configuration
#   AWS free tier (as of 15-09-2022):
#   - 750 hours of t2.micro instances (use t3.micro for regions where t2.micro is 
#     unavailable) per month

# create IAM policy for these instances when they are launched
data "aws_iam_policy_document" "ecs_agent" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "ecs_agent" {
    name               = "ecs-agent"
    assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}

resource "aws_iam_role_policy_attachment" "ecs_agent" {
    role       = aws_iam_role.ecs_agent.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
    name = "ecs-agent"
    role = aws_iam_role.ecs_agent.name
}

# configure autoscaling group containing a collection of EC2
resource "aws_launch_configuration" "ecs_launch_config" {
    image_id             = "ami-05fa00d4c63e32376"
    iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
    security_groups      = [aws_security_group.ecs_sg.id]
    user_data            = "#!/bin/bash\necho ECS_CLUSTER=cti-cluster >> /etc/ecs/ecs.config"
    instance_type        = "t2.micro"
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
    name                      = "asg"
    vpc_zone_identifier       = [aws_subnet.pub_subnet.id]
    launch_configuration      = aws_launch_configuration.ecs_launch_config.name
    desired_capacity          = 2
    min_size                  = 1
    max_size                  = 10
    health_check_grace_period = 300
    health_check_type         = "EC2"
}

# S3 configuration
#   AWS free tier (as of 15-09-2022):
#   - 5GB standard storage
#   - 20,000 GET requests per month
#   - 2,000 PUT/COPY/POST/LIST requests per month
#   - 100 GB data transfer out each month

resource "aws_s3_bucket" "s3_bucket_name" {
    bucket = "cti-ukb-data"
    tags = {
        Name        = "cti-ukb-data"
        Environment = "dev"
    }
}

resource "aws_s3_object" "s3_object" {
    bucket = aws_s3_bucket.s3_bucket_name.id
    key    = "dvc"
}

resource "aws_s3_bucket_acl" "s3_acl" {
    bucket = aws_s3_bucket.s3_bucket_name.id
    acl    = "private"
}

resource "aws_s3_bucket_versioning" "s3_version" {
    bucket = aws_s3_bucket.s3_bucket_name.id
    versioning_configuration {
        status = "Disabled"
    }
}

resource "aws_s3_bucket_public_access_block" "s3_access" {
    bucket                  = aws_s3_bucket.s3_bucket_name.id
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
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
    subnet_ids  = [aws_subnet.pub_subnet.id]
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
    skip_final_snapshot                 = true
    final_snapshot_identifier           = "ukb-db-final"
    publicly_accessible                 = true
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
resource "aws_ecrpublic_repository" "ecr_name" {
  repository_name = "cti-pred"
}

resource "aws_ecrpublic_repository_policy" "ecr_name" {
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

# resource "aws_ecr_repository" "ecr_name" {
#     name                 = "cti-pred"
#     image_tag_mutability = "MUTABLE"
#     image_scanning_configuration {
#         scan_on_push = true
#     }
# }

# ECS configuration
#   - always free and cost depends on usage of AWS compute resources

# create a cluster
resource "aws_ecs_cluster" "ecs_cluster" {
    name  = "cti-cluster"
}

# create a task definition
data "template_file" "task_definition_template" {
    template = file("task_definition.json.tpl")
    vars = {
        REPOSITORY_URL = replace(aws_ecrpublic_repository.ecr_name.repository_uri, "https://", "")
    }
}

resource "aws_ecs_task_definition" "task_definition" {
    family                = "cti-task"
    container_definitions = data.template_file.task_definition_template.rendered
}

# attach task to cluster
resource "aws_ecs_service" "cti-task" {
    name            = "cti-task"
    cluster         = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.task_definition.arn
    desired_count   = 2
}

# Output parameter of provisioned component 
# output "postgresql_endpoint" {
#     value = aws_db_instance.rds_postgresql_name.endpoint
# }

output "ecr_repository_worker_endpoint" {
    value = aws_ecrpublic_repository.ecr_name.repository_uri
}
