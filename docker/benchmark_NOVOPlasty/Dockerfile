ARG baseimageversion=latest
FROM chloroextractorteam/benchmark-baseimage:${baseimageversion}

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

ENV NOVOPLASTYVERSION ff505406c3bc2352b2606789e417239b836fc6bf

WORKDIR /opt
RUN git clone --recursive https://github.com/ndierckx/NOVOPlasty.git && \
    cd NOVOPlasty && \
    git checkout ${NOVOPLASTYVERSION} && \
    rm -rf .git && \
    chmod +x NOVOPlasty*.pl && \
    ln -s NOVOPlasty*.pl NOVOPlasty.pl
ENV PATH "/opt/NOVOPlasty:$PATH"

ADD TAIR10_chrC.fas /opt/reference.fa

ADD wrapper.sh /usr/local/bin/wrapper.sh

ENTRYPOINT ["wrapper.sh"]

# Setup of /data volume and set it as working directory
VOLUME /data
WORKDIR /data
