# Containers
Container build for ufs-wm ci

-old version

docker build -f app/Dockerfile.hpc.ubuntu_20.04.gnu -t my_image-v1.2 .

docker tag my_image-v1.2 jongkim2004/ubuntu-hpc:v1.2

sudo docker login --username=noaaepic

sudo docker images

sudo docker tag my_image-v1.2 noaaepic/ubuntu20.04-gnu9.3-hpc-stack:v1.2

version: 08-09-2023

sudo docker build -f Dockerfile.ubuntu20.04-gnu9.3-hpc-stack.v1.2b -t  ubuntu20.04-gnu9.3-hpc-stack .

sudo docker images

sudo docker tag 72a57b3590b9 noaaepic/ubuntu20.04-gnu9.3-hpc-stack:v2.0

sudo docker login --username=noaaepic

sudo docker push noaaepic/ubuntu20.04-gnu9.3-hpc-stack:v2.0
