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

### Update the Application
- When you want to update your code, re-build the container, and run it, you cannot do so when the current container is still running
- This is because the old container is already using port 3000 (host port) and only one process on the machine can listen to a specific port
- To remove a container, you need to
    - Retrive teh ID of the container
    - Stop the container
    - Remove the container
```
docker ps
docker stop <id-of-container-from-docker-ps>
docker rm <id-of-container-from-docker-ps>
```
- Then you can do ```docker run``` with your updated build, refreash your browser listening to your port 3000, and you should see the updated container running

### Share the Application
- Sign up to DockerHub
- Create repository and make it public
- You will then be prompted with the command to use to push to the repo
- To perform the push to DockerHub, you first have to tag your image locally with the correct repo name
- Then you will be able to push your image to DockerHub, the tagname is optional
```
docker tag getting-started <dockerhub-username>/<repo-name>
docker push <dockerhub-username>/<repo-name>:tagname
```

### Docker Volumes
- Containers provide total isolation in terms of its changes
- Volumes provide the ability to connect specific filesystem paths of the container back to the host machine
- If a directory in the container is mounted, changes can also be seen on the host machine
- ```docker volume create <name>``` creates a mount point for tracking changes
- The default is called named volumes, in which docker chooses the host location
- The other is called bind mounts where you control the host location

### Multi-Container Apps
- The general rule of thumb is each container should only perform one distinct function
- Multiple containers can be connected together through networking
- This allows your application to be built with multiple containers, each isolated from each other for easy management and control, while also talking to eachother to perform a larger function
- The important rule is: if two containers are on the same network, they can talk to each other
- We can create the network with 
```
docker network create <name-of-app>
```
- We can then run a container with 
```
docker run -d
    --network <name-of-app> --network-alias <alias> 
    -v <volume-name>:<volume-path>
```
- We then run a second container with the following, with the ```nicolaka/netshoot``` container, to see the IP address of the first app so we can connect it with the second
- We then can finally run the second container (original app above) by specifying the host of of the first app so they talk to eachother
```
docker run -it --network <name-of-app> nicolaka/netshoot
docker run -dp 3000:3000 `
   -w /app -v "$(pwd):/app" `
   --network <name-of-app> `
   -e HOST=<alias-of-first-app-above>
   node:18-alpine `
   sh -c "yarn install && yarn run dev"
```

### Docker-Compose
- All the above commands can be placed in a simple yaml file which can be executed with docker-compose
- The above can be written as follows
```
services:
  app:
    image: node:18-alpine
    command: sh -c "yarn install && yarn run dev"
    ports:
      - 3000:3000
    working_dir: /app
    volumes:
      - ./:/app
    environment:
      HOST: <alias-of-first-app-above>
      MYSQL_USER: root
      MYSQL_PASSWORD: secret
      MYSQL_DB: todos

  app2:
    image: mysql:8.0
    volumes:
      - <volume-name>:<volume-path>
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: todos

volumes:
  <volume-name>:
```

### DNA Nexus
- 
