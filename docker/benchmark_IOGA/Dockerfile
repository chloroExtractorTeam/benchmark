ARG osversion=latest
FROM chloroextractorteam/benchmark-baseimage:${osversion}

ARG VERSION=master
ARG VCS_REF
ARG BUILD_DATE

RUN echo "VCS_REF: "${VCS_REF}", BUILD_DATE: "${BUILD_DATE}", VERSION: "${VERSION}

LABEL maintainer="frank.foerster@ime.fraunhofer.de" \
      description="Dockerfile providing an image for IOGA for our benchmark setup" \
      version=${VERSION} \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.vcs-url="https://github.com/chloroExtractorTeam/benchmark.git"

ENV IOGAVERSION c460ea9d9fe176fec2bd76d369b0cbb36793b2bf

WORKDIR /opt
RUN git clone --recursive https://github.com/holmrenser/IOGA.git && \
    cd IOGA && \
    git checkout ${IOGAVERSION} && \
    rm -rf .git && \
    python setup_IOGA.py

ENV PATH "/opt/IOGA:$PATH"

# Setup of /data volume and set it as working directory
VOLUME /data
WORKDIR /data
