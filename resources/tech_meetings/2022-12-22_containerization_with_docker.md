### Containerization
- A container is a standard unit of software that packages up code and all its dependencies so the application runs quickly and reliably in multiple computing environments
- An image is a lightweight, standalone, executable package of software that includes everything needed to run an application (code, runtime, system tools, libraries, settings)
- Container images become contaienrs at runtime
- Containerized software will always run the same regardless of infrastructure
- Containers vs Virtual Machines
    - Containers sit on top of an operating system through a container engine (docker)
    - This differs from virtual machines which has its own operating system
- Containers are more light weight as they only include high-level software
- There are many pre-made containers which are available for your development to save time

### Docker
- Build
    - Use docker images to develop unique applications
    - Create multi-container application using docker compose
    - Integrate docker with common tools such as VS code, circleCI, github
    - Paclage applications a portable container images to run in any envirionment (Kubernettes, AWS ECS, Azure ACI, Google GKE)
- Share
    - Leverage docker official images from verified publishers
    - Collaborate with others by easily publishing images on docker hub
    - Personalize access to your images with access control and activity logging
- Run
    - Deliver multiple applications which runs in all environments (design, test, stage, prod)
    - Deploy applications independently to reduce risk of conflict
    - Speed development with Docker Compose CLI to launch your applications locally and on the cloud
- Docker containers that run on docker engine are:
    - Standard (standard containers that are portable anywhere)
    - Lightweight (shares the OS system kernel and do not require an OS per application)
    - Secure (applications are safe inside containers)

### Containerize an Application
- Install Docker: https://docs.docker.com/get-docker/
- Install Git: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
- Clone the demo repository
```
git clone https://github.com/docker/getting-started.git
```
- Building the application's container image
    - A ```Dockerfile``` is used to build a docker image
    - It is a text-based file with a script of instructions to create the image
    - First navigate to the app directory and create a ```Dockerfile```
    - The ```app``` directory contains two subdirectories called ```spec``` and ```src```
    ```
    cd app
    type nul > Dockerfile
    ```
    - Paste the following into the ```Dockerfile```
    ```
    # syntax=docker/dockerfile:1
    FROM node:18-alpine
    WORKDIR /app
    COPY . .
    RUN yarn install --production
    CMD ["node", "src/index.js"]
    EXPOSE 3000
    ```
    - Build the container image with the following command (in the directory where your ```Dockerfile``` is located)
        - The ```docker build``` command uses the ```Dockerfile``` to create a new image
        - The image is consisted of many layers
        - It first installs the ```node:18-alphine``` image
        - It then sets the working directory as ```/app``` and copies all the content of the current directory into the docker image directory
        - It then uses ```yarn``` to install the dependencies
        - It then runs the command to execute ```node.js``` programs from the run file ```src/index.js```
        - Lastly, it exposes port 3000 as the endpoint
    ```
    docker build -t getting-started .
    ```
    - Your image gets tagged with ```-t``` with a name such as ```getting-started```
    - The ```.``` tells docker that it should look for the ```Dockerfile``` in the current directory
    - Once built, you can start your container with
     ```
     docker run -dp 3000:3000 getting-started
     ```
    - The ```d``` is the flag that means we want to run the container in detached mode
    - The ```p``` is the flag to create the mapping between the host's port (3000) to the containers port (also 3000), which is the endpoint needed to access the application
    - Once running, you can see your app at ```http://localhost:3000```

###
