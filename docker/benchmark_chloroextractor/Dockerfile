ARG baseimageversion=latest
FROM chloroextractorteam/benchmark-baseimage:${baseimageversion}

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
ENV CHLOROEXTRACTORVERSION 2723dcd3e7bb94935ab6df27026bd518583eaaae

RUN git clone --recursive https://github.com/chloroExtractorTeam/chloroExtractor.git /opt/chloroExtractor/ && \
    cd /opt/chloroExtractor/ && \
    git checkout ${CHLOROEXTRACTORVERSION} && \
    rm -rf /opt/chloroExtractor/.git

ENV PATH "/opt/chloroExtractor/bin/:$PATH"

ADD wrapper.sh /usr/local/bin/wrapper.sh

ENTRYPOINT ["wrapper.sh"]

# Setup of /data volume and set it as working directory
VOLUME /data
WORKDIR /data
