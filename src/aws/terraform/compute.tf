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
    role = aws_iam_role.ecs_agent.id
}

data "aws_iam_policy_document" "ecs-service-policy" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            type        = "Service"
            identifiers = ["ecs.amazonaws.com"]
        }
    }
}

# define ec2 instance
data "template_file" "user_data" {
    template = file("user_data.tpl")
}

resource "aws_instance" "ec2_instance" {
    ami                    = "ami-03f8a7b55051ae0d4"
    subnet_id              = aws_subnet.pub_subnet1.id
    instance_type          = "t2.micro"
    iam_instance_profile   = aws_iam_instance_profile.ecs_agent.name
    vpc_security_group_ids = [aws_security_group.ecs_sg.id]
    ebs_optimized          = "false"
    source_dest_check      = "false"
    user_data              = data.template_file.user_data.rendered
}

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
        REPOSITORY_URL = aws_ecrpublic_repository.ecr_name1.repository_uri
    }
}

resource "aws_ecs_task_definition" "task_definition" {
    family                   = "cti_model"
    container_definitions    = data.template_file.task_definition_template.rendered
    network_mode             = "awsvpc"
    requires_compatibilities = ["EC2"]
}

# attach task to cluster
resource "aws_ecs_service" "cti-task" {
    name            = "cti_model"
    cluster         = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.task_definition.arn
    desired_count   = 1
    launch_type     = "EC2"
    depends_on      = [aws_lb_listener.lb_listener]
    network_configuration {
        subnets          = [aws_subnet.pub_subnet1.id, aws_subnet.pub_subnet2.id]
        #assign_public_ip = true
    }
    load_balancer {
        container_name   = "cti_model"
        container_port   = "8500"
        target_group_arn = aws_lb_target_group.lb_target_group.arn
    }
}

# configure load balancing
resource "aws_lb" "loadbalancer" {
    name            = "alb-name"
    internal        = false
    subnets         = [aws_subnet.pub_subnet1.id, aws_subnet.pub_subnet2.id] 
    security_groups = [aws_security_group.ecs_sg.id]
}

resource "aws_lb_target_group" "lb_target_group" {
    name        = "target-alb-name"
    port        = "80"
    protocol    = "HTTP"
    vpc_id      = aws_vpc.vpc.id
    target_type = "ip"
    health_check {
        interval            = "300"
        port                = "8500"
        healthy_threshold   = "2"
        unhealthy_threshold = "2"
    }
}

resource "aws_lb_listener" "lb_listener" {
    default_action {
        target_group_arn = aws_lb_target_group.lb_target_group.id
        type             = "forward"
    }
    load_balancer_arn = aws_lb.loadbalancer.arn
    port              = "80"
}

# # configure route53 to access internet
# resource "aws_route53_zone" "r53_private_zone" {
#     name = "zJl7Jv7M0HECtUzgWM93fuZradqoF8eGKPuazYmBygMuUNwAA9hFVIkYbQI6"
# }

# resource "aws_route53_record" "dns" {
#     name    = "name_dns"
#     zone_id = aws_route53_zone.r53_private_zone.zone_id
#     type    = "A"
#     alias {
#         evaluate_target_health = false
#         name                   = aws_lb.loadbalancer.dns_name
#         zone_id                = aws_lb.loadbalancer.zone_id
#     }
# }
