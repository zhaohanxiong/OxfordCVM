[
    {
        "name": "cti_model",
        "image": "${REPOSITORY_URL}:latest",
        "cpu": 2,
        "memory": 512,
        "essential": true,
        "environment": [],
        "entryPoint": [],
        "command": [],
        "mountPoints": [],
        "volumesFrom": [],
        "links": [],
        "portMappings": [
            {
                "containerPort": 8500,
                "hostPort": 8500,
                "protocol": "tcp"
            }
        ]
    }
]