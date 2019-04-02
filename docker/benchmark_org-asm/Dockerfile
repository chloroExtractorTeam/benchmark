ARG osversion=latest
FROM chloroextractorteam/benchmark-baseimage:${osversion}

ARG VERSION=master
ARG VCS_REF
ARG BUILD_DATE

RUN echo "VCS_REF: "${VCS_REF}", BUILD_DATE: "${BUILD_DATE}", VERSION: "${VERSION}

LABEL maintainer="frank.foerster@ime.fraunhofer.de" \
      description="Dockerfile providing an image for ORG-asm for our benchmark setup" \
      version=${VERSION} \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.vcs-url="https://github.com/chloroExtractorTeam/benchmark.git"

ENV ORGASMVERSION e8d013ea9b939c0a05b8a7632e21f001e9c8c516
WORKDIR /opt
RUN git clone https://git.metabarcoding.org/org-asm/org-asm.git && \
    cd org-asm && \
    git checkout ${ORGASMVERSION} && \
    rm -rf .git && \
    python3 setup.py --serenity install

# Setup of /data volume and set it as working directory
VOLUME /data
WORKDIR /data
