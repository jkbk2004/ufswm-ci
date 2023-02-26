# Docker containers
-------------------

This `README.md` describes how to build a hierarchy of Docker containers for use in various applications ranging from NCEPLibs, UFS, GSI, JEDI, and beyond.

There are 3 levels of containers that are made available.  At the very bottom a `BaseContainer` is created that contains only the basic Linux tools such as compilers (`GCC` or `Intel`), MPI implementations (`OpenMPI`, `MPICH` or `Intel MPI`), GNU utils such as `curl`, `wget`, as well as `git`, `cmake`, `vim`, `python`, etc.  [Dockerfile.ubuntu.base](./Dockerfile.ubuntu.base) contains an example of the contents of a `BaseContainer`.

The next level in the hierarchy of containers is an `HPCContainer`.  A `HPCContainer` is built on top of a `BaseContainer` where we build the [hpc-stack](https://github.com/noaa-emc/hpc-stack).  The `hpc-stack` contains all the third-party libraries required for running the applications such as UFS, GSI, JEDI etc.  [Dockerfile.hpc.ubuntu.base](./Dockerfile.hpc.ubuntu.base) contains an example of the contents of a `HPCContainer`.

The top-level in the hierarchy of containers is the `AppContainer`.  An `AppContainer` is built on the `HPCContainer` and typically will contain the application specific tools, codes and static fixed files.  For example, a `UFSContainer` will provide the fix files and static data to compile, build and execute a UFS application.

## How to build Docker containers:
To build these containers, follow the documentation from [Docker](https://docker.com).  Simple examples to create and use the containers are given below as a cheat-sheet.

To build a `Ubuntu` `BaseContainer` called `ncep_base` using this [Dockerfile.ubuntu.base](./Dockerfile.ubuntu.base):

```
$> docker build -t ncep_base:ubuntu -f Dockerfile.ubuntu.base .
$> docker images
REPOSITORY   TAG      IMAGE ID       CREATED       SIZE
ncep_base    ubuntu   c5925a4ef101   6 hours ago   596MB
```

Once the `Ubuntu` `BaseContainer` named `ncep_base` is built, one can build a `HPCContainer` called `hpc_base` using `ncep_base` and this [Dockerfile.hpc.ubuntu.base](./Dockerfile.hpc.ubuntu.base):

```
$> docker build -t hpc_base:ubuntu -f Dockerfile.hpc.base .
$> docker images
REPOSITORY   TAG      IMAGE ID       CREATED       SIZE
hpc_base     ubuntu   4c9391132310   5 hours ago   4.69GB
ncep_base    ubuntu   c5925a4ef101   6 hours ago   596MB
```

## How to start/stop a Docker container:
To start a docker container image e.g. `hpc_base` and `ssh` into it:

```
$> docker run -it <dockerImageName>
```

NOTE: Once you log out or exit out of the container, your local work will be lost.  To save work on the local disk see Docker documentation.


## Installing Docker
-------------------

This section of the `README.md` will describe how to setup a docker environment.  This is useful in transforming docker images into singularity images from the local environment (as opposed to transforming a dockerhub based docker image)

This section of the guide only describes how to install docker on a Ubuntu-based linux environment which has root level permissions.  For a more complete guide of a docker installation for various platforms see this link [here](https://docs.docker.com/engine/install) and for specific platforms see the following links.

- [Docker Desktop for Mac (macOS)](https://docs.docker.com/docker-for-mac/install/)

- [Docker Desktop for Windows](https://docs.docker.com/docker-for-windows/install/)

- [Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

- [CentOS](https://docs.docker.com/engine/install/centos/)

1. Uninstall any existing older versions of docker.

```bash
$ sudo apt-get remove docker docker-engine docker.io containerd runc
```

2. Update the apt package index and install packages.  This will allow apt to use a repository over HTTPS.

```bash
$ sudo apt-get update

$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
```

3. Add Docker’s official GPG key.

```bash
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

4. Verify that you now have the key with the fingerprint `9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88`, by searching for the last 8 characters of the fingerprint.

```bash
$ sudo apt-key fingerprint 0EBFCD88

pub   rsa4096 2017-02-22 [SCEA]
     9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
sub   rsa4096 2017-02-22 [S]
```

5. Setup the repository.  Use the following command to set up the stable repository. To add the nightly or test repository, add the word nightly or test (or both) after the word stable in the commands below.

```bash
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

6. Install the docker engine.
    - Update the apt package index, and install the latest version of Docker Engine and `containerd`, or go to the next step to install a specific version:

```bash
$ sudo apt-get update

$ sudo apt-get install docker-ce docker-ce-cli containerd.io
```

7. Verify that Docker Engine is installed correctly by running the `hello-world` image.

```bash
$ sudo docker run hello-world

Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
0e03bdcc26d7: Pull complete
Digest: sha256:8c5aeeb6a5f3ba4883347d3747a7249f491766ca1caa47e5da5dfcf6b9b717c0
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

8. Add your user to the `docker` group. If you would like to use Docker as a non-root user, you should now consider adding your user to the “docker” group with something like:

```bash
$ sudo usermod -aG docker your-user
```

Remember to log out and back in for this to take effect!

## Setup a Local Docker Registry (For Singularity)

This is the easiest way to enable the transformation into a singularity image mechanism.  You can read more about creating a private registry [here](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-18-04). The local docker registry service is described [here](https://docs.docker.com/registry/) and a local registry setup guide can be found [here](https://docs.docker.com/registry/deploying/) if you wish to set it up in more complex ways than just localhost.

This guide will walk you through the quick setup instructions which can also be found [here](https://hub.docker.com/_/registry).

1. Start the local registry at port 5000.

```bash
$ docker run -d -p 5000:5000 --restart always --name registry registry:2
```

2. Now, use it from within Docker (there are 3 basic steps to making a docker image available
for a singularity transformation):

    - create the docker image using the `docker build` command
    - tag that image using the `docker tag` command
    - push that image to your local registry using the `docker push` command. in this example, a pre-built docker image is pulled from dockerhub, so instead of pulling an image, simply build the image you wish to transform locally

```bash
$ docker build -t <docker_image_name>:<version> -f <docker_definition_file>
$ docker tag ubuntu localhost:5000/ubuntu
$ docker push localhost:5000/ubuntu
```
