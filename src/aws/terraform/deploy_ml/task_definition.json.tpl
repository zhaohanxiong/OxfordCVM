[
    {
        "name": "cti-task",
        "image": "${REPOSITORY_URL}:latest",
        "cpu": 2,
        "memory": 512,
        "essential": true,
        "environment": [],
        "portMappings": [
            {
                "containerPort": 8500,
                "hostPort": 8500
            }
        ]
    }
]