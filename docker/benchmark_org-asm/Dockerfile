ARG baseimageversion=latest
FROM chloroextractorteam/benchmark-baseimage:${baseimageversion}

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

ENV ORGASMVERSION 830313acae3ca773b63f6bea9fc6d017e021bde5
WORKDIR /opt
RUN git clone https://git.metabarcoding.org/org-asm/org-asm.git && \
    cd org-asm && \
    git checkout ${ORGASMVERSION} && \
    rm -rf .git && \
    python3.7 get_orgasm/get-orgasm.py

ENV PATH "/opt/org-asm/ORG.asm-1.0.3/bin:$PATH"

ADD wrapper.sh /usr/local/bin/wrapper.sh

ENTRYPOINT ["wrapper.sh"]

# Setup of /data volume and set it as working directory
VOLUME /data
WORKDIR /data
