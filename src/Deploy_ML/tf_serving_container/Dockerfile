FROM tensorflow/serving

# Define metadata
LABEL author="ZHX"
LABEL version="1.0"
LABEL description="Deploy cTI IG with tf-serving"

# Copy model
WORKDIR /IG
RUN mkdir -p cTI_pred/1
RUN mkdir -p cTI_pred/1/variables
ADD IG/saved_model.pb cTI_pred/1/

EXPOSE 80
ENTRYPOINT ["tensorflow_model_server", "--model_base_path=/IG/cTI_pred"]
CMD ["--rest_api_port=8501", "--port=8501"]
