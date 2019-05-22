ARG baseimageversion=latest
FROM chloroextractorteam/benchmark-baseimage:${baseimageversion}

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

RUN apt install --yes libperl4-corelibs-perl

ENV CHLOROPLASTASSEMBLYPROTOCOL 250d16ac02005d6a5939bf182b3d2995d0e88229
WORKDIR /opt
RUN git clone https://github.com/eead-csic-compbio/chloroplast_assembly_protocol.git && \
    cd chloroplast_assembly_protocol && \
    git checkout ${CHLOROPLASTASSEMBLYPROTOCOL} && \
    rm -rf .git

ENV PATH "/opt/chloroplast_assembly_protocol:$PATH"

RUN perl /opt/chloroplast_assembly_protocol/install.pl && \
    sed -i '/^[[:space:]]*my \$CPUTHREADS = 4;/{=;s/^\([[:space:]]*my \$CPUTHREADS = 4;.*\)/my $CPUTHREADS = (exists $ENV{NUMCPUS} && $ENV{NUMCPUS} =~ \/^\\d+$\/) ? $ENV{NUMCPUS} : 4; # old line content: \1/};' /opt/chloroplast_assembly_protocol/1_cleanreads.pl

ADD TAIR10_chrC.fas /opt/reference.fa

ADD wrapper.sh /usr/local/bin/wrapper.sh

ENTRYPOINT ["wrapper.sh"]

# Setup of /data volume and set it as working directory
VOLUME /data
WORKDIR /data
