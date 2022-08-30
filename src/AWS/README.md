##### Navigate to docker folder
```
cd ..\ml_lifecycle\tf_serving
```

##### AWS configure ECR with CLI (access keys = IAM.csv, account ID = 956279893231)
```
aws configure
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 956279893231.dkr.ecr.us-east-1.amazonaws.com

- create a new repository in ECR and save the link (shown below) & access IAM token
```

##### Tag/Push image to AWS ECR
```
docker tag cti_model 956279893231.dkr.ecr.us-east-1.amazonaws.com/cti_pred
docker push 956279893231.dkr.ecr.us-east-1.amazonaws.com/cti_pred
```

##### Setup Fargate, connect with ECS and ECR, and deploy
```
- define ECS task definition by linking with ECR URI and exposing port 8500
- create AWS ECS cluster with fargate for serverless compute (without managing EC2)
- create task in ECS cluster by linking with task definition from above, also expose port 8500
- copy public IP address from newly running task and copy into python grpc channel handle
```
