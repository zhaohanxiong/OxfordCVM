### Pull and build tensorflow-serving image from docker repo
```
docker pull tensorflow/serving
docker build -t tensorflow/serving .
```

### Run docker image using current model to create container
### Note for this the file structure needs to contain sub-folders of /1/ or /2/ etc
### Under the /saved_models for it to work. It will pick the latest model version
```
docker run -p8500:8500 -p8501:8501 --mount type=bind,source=C:/Users/86155/OneDrive/Post-Doc/OxfordCVM/src/Deploy_ML/tf_serving_container/saved_models/,target=/models/cti_model -e MODEL_NAME=cti_model -t tensorflow/serving
```

### Running with dockerfile to build custom image which can host multiple models (expose both 8500/8501)
### In the model.config file you can define multiple models by seperating with "," and adding new "config:"
```
docker build -t cti_model .
docker run -p8500:8500 -p8501:8501 cti_model
```
