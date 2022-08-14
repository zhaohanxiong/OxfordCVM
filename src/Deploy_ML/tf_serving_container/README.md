##### Pull and build tensorflow-serving image from docker repo
```
docker pull tensorflow/serving
docker build -t tensorflow/serving .
```

##### Run docker image using current model to create container
##### Note for this the file structure needs to contain sub-folders of /1/ or /2/ etc
##### Under the /saved_models for it to work. It will pick the latest model version
```
docker run -p8500:8500 -p8501:8501 --mount type=bind,source=C:/Users/86155/OneDrive/Post-Doc/OxfordCVM/src/Deploy_ML/tf_serving_container/saved_models/,target=/models/cti_model -e MODEL_NAME=cti_model -t tensorflow/serving
```

##### Running with dockerfile to build custom image which can host multiple models (expose both 8500/8501)
##### In the model.config file you can define multiple models by seperating with "," and adding new "config:"
```
docker build -t cti_model .
docker run -p8500:8500 -p8501:8501 cti_model
```

##### Running docker compose (robust configuration), only works for gRPC
```
docker-compose build
docker-compose up
```

##### AWS configure ECR (access keys = IAM.csv, account ID = 956279893231)
```
aws configure
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 956279893231.dkr.ecr.us-east-1.amazonaws.com
```

##### Tag/Push image to AWS ECR and deploy with ECS
```
docker tag cti_model 956279893231.dkr.ecr.us-east-1.amazonaws.com/cti_pred
docker push 956279893231.dkr.ecr.us-east-1.amazonaws.com/cti_pred

- define ECS task definition by linking with ECR URL and exposing port 8500
- create AWS ECS cluster with fargate for serverless compute (without managing EC2)
- create task in ECS cluster by linking with task definition from above, also expose port 8500
- copy public IP address from newly running task and copy into python grpc channel handle
```
