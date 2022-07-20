FROM python:3.10-slim

# create directory
RUN mkdir /app
WORKDIR /app

# install dependencies
RUN pip install tensorflow \
                pandas

# to COPY the remote file at working directory in container
COPY predict.py ./
COPY saved_model.pb ./

# run code
CMD ["python", "predict.py"]
