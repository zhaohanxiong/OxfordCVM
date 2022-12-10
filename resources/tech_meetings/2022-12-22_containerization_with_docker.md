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
