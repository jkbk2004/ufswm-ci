# Singularity Container Development Instructions
------------------------------------

## Install Singularity
Now if you haven't already done so, install Singularity.  The `singularity` binary must be built by `go`, so `go` must be installed first.

1. Install Singularity dependencies.

```bash
$ export DEBIAN_FRONTEND=noninteractive

# package dependencies
$ apt-get update -y
$ apt-get install -y --no-install-recommends \
      build-essential git openssh-server libncurses-dev libssl-dev libx11-dev \
      less bc file flex bison libexpat1-dev wish curl wget libcurl4-openssl-dev \
      libgtk2.0-common software-properties-common xserver-xorg dirmngr gnupg2 \
      lsb-release apt-utils uuid-dev libgpgme11-dev squashfs-tools
```

2. Install `go`

    - The minimum required version is determined by the version of Singularity. See the latest singularity documentation for up-to-date information [here](https://sylabs.io/docs/).

```bash
if [ -z "${HOME:-}" ]; then export HOME="$(cd ~ && pwd)"; fi
cd ${HOME}
export VERSION=1.15.2 OS=linux ARCH=amd64
wget -nv --no-check-certificate https://golang.org/dl/go$VERSION.$OS-$ARCH.tar.gz
tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz
rm -f go$VERSION.$OS-$ARCH.tar.gz
echo 'export GOPATH=${HOME}/go' >> ${HOME}/.bashrc
echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> ${HOME}/.bashrc
export GOPATH=${HOME}/go
export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin
```

3. Build and install Singularity

```bash
PREFIX=/opt/singularity
mkdir -p ${PREFIX}
cd ${PREFIX}
export VERSION=3.6.3
wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz
tar -xzf singularity-${VERSION}.tar.gz
cd singularity
./mconfig
make -C builddir
make -C builddir install
rm ${PREFIX}/singularity-${VERSION}.tar.gz
```

4. Validate the installation by running the following command.

```bash
$ singularity --version

singularity version 3.6.3
```

## Create Singularity Image from Local Docker Image

This guide describes the process of transforming a Docker image into a Singularity Image.  Please follow the instructions in the [Docker/README.MD](../Docker/README.md) to setup and use Docker for the purpose of creating Docker images for Singularity.

1. First confirm that the Docker image is available on your private registry.

```bash
$ curl localhost:5000/v2/_catalog

# example output (note, look for the docker images which you have tagged and pushed to the registry)
{"repositories":["intel-oneapi-ufs-s2s-dev","intel-oneapi-ufs-s2s-lite"]}
```

2. Transform the docker image into a singularity image. Note, the `SINGULARITY_NOHTTPS=1` ensures that singularity does not try to grab the tagged image from dockerhub.  You want singularity to grab the image from your locally hosted registry, not a remote registry.

```bash
$ SINGULARITY_NOHTTPS=1 singularity build <desired_image_name>.sif docker://localhost:5000/<docker_image_tag_name>
```
> The singularity image should now be ready for use.
