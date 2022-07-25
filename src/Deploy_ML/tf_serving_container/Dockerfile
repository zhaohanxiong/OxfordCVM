# pull image from docker container repo
FROM tensorflow/serving

# copy and create working directory in docker container
RUN mkdir /app
COPY . /app
WORKDIR /app

# for gRPC 8500, for REST use 8501
EXPOSE 8500 8501

# load model config into container, able to define multiple models this way in model.config
ENTRYPOINT ["tensorflow_model_server", "--model_config_file=/app/model.config"]

# set the operations to expose REST/gRPC ports
CMD ["--rest_api_port=8501", "--port=8500"]
