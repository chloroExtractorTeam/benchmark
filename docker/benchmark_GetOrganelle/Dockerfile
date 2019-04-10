ARG osversion=latest
FROM chloroextractorteam/benchmark-baseimage:${osversion}

ARG VERSION=master
ARG VCS_REF
ARG BUILD_DATE

RUN echo "VCS_REF: "${VCS_REF}", BUILD_DATE: "${BUILD_DATE}", VERSION: "${VERSION}

LABEL maintainer="frank.foerster@ime.fraunhofer.de" \
      description="Dockerfile providing an image for GetOrganelle for our benchmark setup" \
      version=${VERSION} \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.vcs-url="https://github.com/chloroExtractorTeam/benchmark.git"

RUN apt install --yes \
    python-scipy \
    python-numpy \
    python-sympy

ENV GETORGANELLEVERSION b2e29d6d9372246535d42063430f51280766a741

WORKDIR /opt
RUN git clone --recursive https://github.com/Kinggerm/GetOrganelle.git && \
    cd GetOrganelle && \
    git checkout ${GETORGANELLEVERSION} && \
    rm -rf .git

ENV PATH "/opt/GetOrganelle:/opt/GetOrganelle/Utilities:$PATH"

ADD wrapper.sh /usr/local/bin/wrapper.sh

ENTRYPOINT ["wrapper.sh"]

# Setup of /data volume and set it as working directory
VOLUME /data
WORKDIR /data
