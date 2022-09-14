
##### AWS Configuring Command Line Interface (CLI)
```
- create policy in AWS Identifiy Authentication Manager (IAM)
- download the .csv file containing the public/private keys
aws configure
- give CLI permission to access AWS by inputting the keys from .csv file (use empty/default settings for others)
```

##### Deploy Container to AWS ECR/ECS with Fargate
```
- create a new repository in ECR and save the link (shown below) & access IAM token
- configure AWS CLI to have access to new ECR (account ID = 956279893231)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 956279893231.dkr.ecr.us-east-1.amazonaws.com

- tag docker image on ur own computer (located in ..\ml_lifecycle\tf_serving)
docker tag cti_model 956279893231.dkr.ecr.us-east-1.amazonaws.com/cti_pred

- push docker image to ECR (using format/link below)
docker push 956279893231.dkr.ecr.us-east-1.amazonaws.com/cti_pred

- create AWS ECS cluster with fargate for serverless compute (without managing EC2)
- create ECS task definition by linking with ECR URI and exposing port 8500
- create task in ECS cluster by linking with task definition from above, also expose port 8500
- copy public IP address from newly running task and copy into python grpc channel handle
```


##### Infrastructure as Code (IaC) with Terraform
```

```
