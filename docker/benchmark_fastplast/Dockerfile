ARG osversion=latest
FROM chloroextractorteam/benchmark-baseimage:${osversion}

ARG VERSION=master
ARG VCS_REF
ARG BUILD_DATE

RUN echo "VCS_REF: "${VCS_REF}", BUILD_DATE: "${BUILD_DATE}", VERSION: "${VERSION}

LABEL maintainer="frank.foerster@ime.fraunhofer.de" \
      description="Dockerfile providing an image for fast-plast for our benchmark setup" \
      version=${VERSION} \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.vcs-url="https://github.com/chloroExtractorTeam/benchmark.git"

WORKDIR /opt
ENV FASTPLASTVERSION ff9755f90791270af70f74d666cced05c211e682
RUN git clone https://github.com/mrmckain/Fast-Plast.git && \
    cd Fast-Plast && \
    git checkout ${FASTPLASTVERSION} && \
    rm -rf .git && \
    cd afin && \
    make && \
    cd .. && \
    echo "yes\n/usr/share/java\npath\n"$(dirname $(which spades.py))"\npath\npath\npath\nYes\npath" | perl INSTALL.pl && \
    sed -i 's#\(my $TRIMMOMATIC="\)[^"]*#\1'$(find /usr -name "trimmomatic.jar")'#;s#\(my $BLAST="\)[^"]*#\1'$(dirname $(which blastn))'/#;' fast-plast.pl
# first sed command sets TRIMMOMATIC location
# second sed command adds the BLAST folder location

ENV PATH "/opt/Fast-Plast/:$PATH"

ADD wrapper.sh /usr/local/bin/wrapper.sh

ENTRYPOINT ["wrapper.sh"]

# Setup of /data volume and set it as working directory
VOLUME /data
WORKDIR /data
