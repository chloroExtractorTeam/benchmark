ARG osversion=latest
FROM chloroextractorteam/benchmark-baseimage:${osversion}

ARG VERSION=master
ARG VCS_REF
ARG BUILD_DATE

RUN echo "VCS_REF: "${VCS_REF}", BUILD_DATE: "${BUILD_DATE}", VERSION: "${VERSION}

LABEL maintainer="frank.foerster@ime.fraunhofer.de" \
      description="Dockerfile providing an image for NOVOPlasty for our benchmark setup" \
      version=${VERSION} \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.vcs-url="https://github.com/chloroExtractorTeam/benchmark.git"

ENV NOVOPLASTYVERSION e8329aea1fc35d385ad6ad2fb1b7b22c630a760c

WORKDIR /opt
RUN git clone --recursive https://github.com/ndierckx/NOVOPlasty.git && \
    cd NOVOPlasty && \
    git checkout ${NOVOPLASTYVERSION} && \
    rm -rf .git && \
    ln -s NOVOPlasty2.7.2.pl NOVOPlasty.pl
ENV PATH "/opt/NOVOPlasty:$PATH"

# Setup of /data volume and set it as working directory
VOLUME /data
WORKDIR /data
