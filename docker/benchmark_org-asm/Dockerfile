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
RUN apt purge --yes python3* && \
    apt install --yes \
       build-essential \
       checkinstall \
       libbz2-dev \
       libc6-dev \
       libgdbm-dev \
       libncursesw5-dev \
       libreadline-gplv2-dev \
       libssl-dev \
       libsqlite3-dev \
       tk-dev \
       libffi-dev && \
    cd /opt/ && \
    wget -O - https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tgz | \
	tar xzf - && \
    cd Python-3.7.3 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf Python-3.7.3 && \
    git clone https://git.metabarcoding.org/org-asm/org-asm.git && \
    cd org-asm && \
    git checkout ${ORGASMVERSION} && \
    rm -rf .git && \
    python3 setup.py --serenity install

ADD wrapper.sh /usr/local/bin/wrapper.sh

ENTRYPOINT ["wrapper.sh"]

# Setup of /data volume and set it as working directory
VOLUME /data
WORKDIR /data
