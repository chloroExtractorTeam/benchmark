#!/bin/bash

TYPE=$1
REPLICATE=$2
NAME=$3
OUTPUTDIR=$4

LOGBASE=~/projects/benchmark/benchmark/performance/performance/logs/"${TYPE}"_"${REPLICATE}"_"${NAME}"

DOCKERID=$(docker run -v ${OUTPUTDIR}:/data --workdir /data/${REPLICATE} --user $(id -u):$(id -g) --name ${NAME} -d chloroextractorteam/benchmark_${TYPE}:v2.0.0)

while true
do
    date +"%Y%m%d-T-%H:%M:%S" >>${LOGBASE}.docker-stats.log;
    docker stats ${DOCKERID} --no-stream >>${LOGBASE}.docker-stats.log;

    date +"%Y%m%d-T-%H:%M:%S" >>${LOGBASE}.du.log;
    du --apparent-size --bytes -s ${OUTDIR} >>${LOGBASE}.du.log;

    curl --silent --unix-socket /var/run/docker.sock http://localhost/containers/${DOCKERID}/stats | head -n1 >>${LOGBASE}.stats.json

    docker ps --no-trunc | grep ${DOCKERID} >/dev/null;
    if [ $? -ne 0 ]
    then
	break;
    fi
done

docker logs --timestamps ${NAME} &>${LOGBASE}.log

curl --silent --unix-socket /var/run/docker.sock http://localhost/containers/${DOCKERID}/json >${LOGBASE}.json
docker rm ${DOCKERID}
