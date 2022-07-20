# copy .pb file into this directory

# build the image with a chosen name in the current directory
docker build -t simple_cti_pred .

# run the image
docker run simple_cti_pred

# this packages the prediction code but cannot actully make predictions
# as it cannot detect the file to predict since its not inside the container
# and there is also no access point for container to see file