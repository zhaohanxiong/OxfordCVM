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

# create a launch configuration for the ecs service
resource "aws_launch_configuration" "ecs_launch_config" {
    image_id             = "ami-05fa00d4c63e32376"
    iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
    security_groups      = [aws_security_group.ecs_sg.id]
    user_data            = "#!/bin/bash\necho ECS_CLUSTER=default >> /etc/ecs/ecs.config"
    instance_type        = "t2.micro"
}

# configure autoscaling group containing a collection of EC2
resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
    name                      = "asg"
    vpc_zone_identifier       = [aws_subnet.pub_subnet.id]
    launch_configuration      = aws_launch_configuration.ecs_launch_config.name
    desired_capacity          = 1
    min_size                  = 1
    max_size                  = 1
    health_check_type         = "EC2"
}

# ECS configuration
#   - always free and cost depends on usage of AWS compute resources

# create a cluster
resource "aws_ecs_cluster" "ecs_cluster" {
    name  = "default"
}

# create a task definition
data "template_file" "task_definition_template" {
    template = file("task_definition.json.tpl")
    vars = {
        REPOSITORY_URL = replace(aws_ecrpublic_repository.ecr_name.repository_uri, "https://", "")
    }
}

resource "aws_ecs_task_definition" "task_definition" {
    family                = "cti_model"
    container_definitions = data.template_file.task_definition_template.rendered
    memory                   = 500
    network_mode             = "host"
    requires_compatibilities = ["EC2"]
}

# attach task to cluster
resource "aws_ecs_service" "cti-task" {
    name            = "cti_model"
    cluster         = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.task_definition.arn
    desired_count   = 1
}
