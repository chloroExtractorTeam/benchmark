ARG osversion=latest
FROM chloroextractorteam/benchmark-baseimage:${osversion}

ARG VERSION=master
ARG VCS_REF
ARG BUILD_DATE

RUN echo "VCS_REF: "${VCS_REF}", BUILD_DATE: "${BUILD_DATE}", VERSION: "${VERSION}

LABEL maintainer="frank.foerster@ime.fraunhofer.de" \
      description="Dockerfile providing an image for chloroExtractor for our benchmark setup" \
      version=${VERSION} \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.vcs-url="https://github.com/chloroExtractorTeam/benchmark.git"

### Installation of chloroExtractor
ENV CHLOROEXTRACTORVERSION 92cca827f4956af1eb9a0820c8cf4cff9387b461
RUN git clone --recursive https://github.com/chloroExtractorTeam/chloroExtractor.git /opt/chloroExtractor/ && \
    cd /opt/chloroExtractor/ && \
    git checkout ${CHLOROEXTRACTORVERSION} && \
    rm -rf /opt/chloroExtractor/.git

ENV PATH "/opt/chloroExtractor/bin/:$PATH"

# Setup of /data volume and set it as working directory
VOLUME /data
WORKDIR /data
