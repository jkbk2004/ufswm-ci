FROM ubuntu:20.04
RUN apt-get update -y && \
   DEBIAN_FRONTEND=noninteractive \
   apt-get install -y --no-install-recommends \
           autoconf \
           automake \
           curl \
           g++ \
           gcc \
           gfortran \
           git \
           libcurl4-openssl-dev \
           libmpich-dev \
           libtool \
           libexpat1-dev \
           make \
           pkg-config \
           vim \
           wget \
           unzip \
           rsync \
           python3-dev \
           python3-pip

RUN cd /tmp \
 && curl -fsSRLO https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2-Linux-x86_64.tar.gz \
 && mkdir -p /usr/local/cmake \
 && tar zxvf cmake-3.20.2-Linux-x86_64.tar.gz -C /usr/local/cmake --strip-components=1 \
 && rm -f cmake-3.20.2-Linux-x86_64.tar.gz
ENV PATH="/usr/local/cmake/bin:${PATH}"

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN groupadd -g 1002 builder && useradd -u 1008 -g 1002 -ms /bin/bash builder
WORKDIR /home/builder
USER builder
CMD ["/bin/bash"]
