ARG osversion=latest
FROM chloroextractorteam/benchmark-baseimage:${osversion}

ARG VERSION=master
ARG VCS_REF
ARG BUILD_DATE

RUN echo "VCS_REF: "${VCS_REF}", BUILD_DATE: "${BUILD_DATE}", VERSION: "${VERSION}

LABEL maintainer="frank.foerster@ime.fraunhofer.de" \
      description="Dockerfile providing an image for chloroplast-assembly-protocol for our benchmark setup" \
      version=${VERSION} \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.vcs-url="https://github.com/chloroExtractorTeam/benchmark.git"

ENV CHLOROPLASTASSEMBLYPROTOCOL 750e241f2a51c3989d59a9c58ab48c4709aa9ccb
WORKDIR /opt
RUN git clone https://github.com/eead-csic-compbio/chloroplast_assembly_protocol.git && \
    cd chloroplast_assembly_protocol && \
    git checkout ${CHLOROPLASTASSEMBLYPROTOCOL} && \
    rm -rf .git

ENV PATH "/opt/chloroplast_assembly_protocol:$PATH"

RUN perl /opt/chloroplast_assembly_protocol/install.pl

# Setup of /data volume and set it as working directory
VOLUME /data
WORKDIR /data
