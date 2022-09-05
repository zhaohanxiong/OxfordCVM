##### Navigate to docker folder
```
cd ..\ml_lifecycle\tf_serving
```

##### Setup Fargate, connect with ECS and ECR, and deploy
```
- create IAM policy, attach policies to ECS/ECR
- create ECR registery
- tag docker image on ur own device
- give docker CLI permission to access AWS
- push docker image to ECR
- create AWS ECS cluster with fargate for serverless compute (without managing EC2)
- define ECS task definition by linking with ECR URI and exposing port 8500
- create task in ECS cluster by linking with task definition from above, also expose port 8500
- copy public IP address from newly running task and copy into python grpc channel handle
```

##### AWS configure ECR with CLI (access keys = IAM.csv, account ID = 956279893231)
```
aws configure
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 956279893231.dkr.ecr.us-east-1.amazonaws.com
```

##### Tag/Push image to AWS ECR
```
- create a new repository in ECR and save the link (shown below) & access IAM token
docker tag cti_model 956279893231.dkr.ecr.us-east-1.amazonaws.com/cti_pred
docker push 956279893231.dkr.ecr.us-east-1.amazonaws.com/cti_pred
```
