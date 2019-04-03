ARG osversion=bionic-20190307
FROM ubuntu:${osversion}

ARG VERSION=master
ARG VCS_REF
ARG BUILD_DATE

RUN echo "VCS_REF: "${VCS_REF}", BUILD_DATE: "${BUILD_DATE}", VERSION: "${VERSION}

LABEL maintainer="frank.foerster@ime.fraunhofer.de" \
      description="Dockerfile providing the base image for our benchmark setup" \
      version=${VERSION} \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.vcs-url="https://github.com/chloroExtractorTeam/benchmark.git"

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt install --yes software-properties-common && \
    add-apt-repository --yes ppa:deadsnakes/ppa && \
    apt update && apt install --yes \
    liblog-log4perl-perl \
    libmoose-perl \
    libfile-which-perl \
    libipc-run-perl \
    libterm-progressbar-perl \
    libgraph-perl \
    liblist-moreutils-perl \
    bowtie2 \
    bowtie \
    build-essential \
    trimmomatic \
    ncbi-blast+ \
    samtools \
    bedtools \
    r-base \
    ghostscript \
    jellyfish \
    python \
    wget \
    python3.7 \
    python3-pip \
    python3-venv \
    python-wget \
    git

RUN cd /tmp/ && \
    wget -O - http://cab.spbu.ru/files/release3.13.0/SPAdes-3.13.0-Linux.tar.gz | \
       tar -xzf - && \
    mv SPAdes-3.13.0-Linux/ /opt//spades/

RUN pip3 install -U pip && \
    pip install -U sphinx && \
    pip install -U cython

ENV PATH "/opt/spades/bin:$PATH"

ADD get_versions.sh /usr/local/bin/get_versions.sh

# Setup of /data volume and set it as working directory
VOLUME /data
WORKDIR /data
