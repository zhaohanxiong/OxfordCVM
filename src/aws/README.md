##### AWS Configuring Command Line Interface (CLI)
```
- Create policy in AWS Identifiy Authentication Manager (IAM)
- Download the .csv file containing the public/private keys

- Open CMD as administrator and type the command:
aws configure

- Give CLI permission to access AWS by inputting the keys from .csv file (use empty/default settings for others)
- Now you can use the command line in windows (powershell or cmd) to execute commands to AWS
```

##### Deploy Container to AWS ECR/ECS with Fargate
```
- Create a new repository in ECR and save the link (shown below) & access IAM token

- Configure AWS CLI to have access to new ECR (account ID = 956279893231):
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 956279893231.dkr.ecr.us-east-1.amazonaws.com

- Tag docker image on ur own computer (located in ..\ml_lifecycle\tf_serving):
docker tag cti_model 956279893231.dkr.ecr.us-east-1.amazonaws.com/cti_pred

- Push docker image to ECR (using format/link below):
docker push 956279893231.dkr.ecr.us-east-1.amazonaws.com/cti_pred

- Cluster: Create AWS ECS cluster with fargate for serverless compute (without managing EC2)
- Task: Create ECS task definition by linking with ECR URI and exposing port 8500
- Service: Create service in ECS cluster by linking with task definition from above, also expose port 8500
- Copy public IP address from newly running task and copy into python grpc channel handle
```

##### Infrastructure as Code (IaC) with Terraform
```
- Download terraform and add it to environment variables
	- Search "Edit Environment Variables" in windows search bar
	- Select "Environment variables"
	- Under "System Variables"
	- Under the "Variables" columns Select "Path" > "Edit" > "New"
	- Add the path of terraform executable (C:\terraform.exe)
	- Under "User Variables"
	- Under the "Variables" columns Select "Path" > find variable with "%USERPROFILE%\AppData ..."
	- Add terraform path to this existing variable with a comma in between (, C:\terraform.exe)

- Open CMD to check terraform correctly installed
.\terraform.exe -version

- Initialize terraform environment through terminal where the .tf files are located
.\terraform.exe init

- Check the terraform infrastructure configuration it will produce
.\terraform.exe plan

- Execute the terraform plan (type yes to proceed with config)
.\terraform.exe apply

- Save current plan and destroy the plan we had
.\terraform.exe plan -destroy -out="destroy.plan"
.\terraform.exe apply destroy.plan
```

##### Terraform Config Files for each AWS Component
```
configure.tf sets up the AWS environment, VPCs, security groups
storage.tf sets up AWS S3, RDS, and ECR
compute.tf set up AWS ECS with either EC2 or Fargate
```
