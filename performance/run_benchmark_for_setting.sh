#!/bin/bash

PROGRAM2CALL=$1
THREADS=$2
LENGTH_READS=$3
READ_RATIO=$4
AMOUNT=$5
REPLICATE=$6

VERSION=v1.0

declare -A PROGRAM2FOLDER=( [chloroextractor]="chloroextractor" [fast-plast]="fast-plast" [getorganelle]="get_organelle" [org-asm]="org-asm" [chloroplast-assembly-protocol]="chloroplastassemblyprotocol" [ioga]="ioga" [novoplasty]="novo_plasty" )
declare -A PROGRAM2DOCKERIMAGE=( [chloroextractor]="chloroextractorteam/benchmark_chloroextractor" [fast-plast]="chloroextractorteam/benchmark_fastplast" [getorganelle]="chloroextractorteam/benchmark_getorganelle" [org-asm]="chloroextractorteam/benchmark_org-asm" [chloroplast-assembly-protocol]="chloroextractorteam/benchmark_chloroplast_assembly_protocol" [ioga]="chloroextractorteam/benchmark_ioga" [novoplasty]="chloroextractorteam/benchmark_novoplasty" )

OUTFOLDER=""
if [ ${PROGRAM2FOLDER[${PROGRAM2CALL}]+_} ]
then
    OUTFOLDER=${PROGRAM2FOLDER[${PROGRAM2CALL}]}
else
    echo "Unable to find folder for ${PROGRAM2CALL}"
    exit
fi

DOCKERIMAGE=""
DOCKERIMAGEVERSION="v2.0.0"
if [ ${PROGRAM2DOCKERIMAGE[${PROGRAM2CALL}]+_} ]
then
    DOCKERIMAGE=${PROGRAM2DOCKERIMAGE[${PROGRAM2CALL}]}":"${DOCKERIMAGEVERSION}
else
    echo "Unable to find docker image for ${PROGRAM2CALL}"
    exit
fi


NAME="${PROGRAM2CALL}"_"${THREADS}"_"${LENGTH_READS}"_"${READ_RATIO}"_"${AMOUNT}"_"${REPLICATE}"
LOGBASE=~/projects/benchmark/benchmark/performance/performance/logs/"${NAME}"
OUTPUTDIR=~/projects/benchmark/benchmark/performance/performance/sim_"${LENGTH_READS}"bp/"${READ_RATIO}"/"${AMOUNT}"/

cat <<EOF

C H L O R O P L A S T   A S S E M B L Y   T O O L   B E N C H M A R K
=====================================================================

Version ${VERSION}

Parameters:
   Assembler:                ${PROGRAM2CALL}
   Threads:                  ${THREADS}
   Read length:              ${LENGTH_READS}
   Genome-chloroplast ratio: ${READ_RATIO}
   Input read number:        ${AMOUNT}
   Replicate number:         ${REPLICATE}

Output:
   Docker image to use:      ${DOCKERIMAGE}
   Execution folder:         ${OUTPUTDIR}
   Assembler output folder:  ${OUTFOLDER}
   Name of output file:      ${NAME}
   Basename of logfolder:    ${LOGBASE}

EOF

cd ${OUTPUTDIR}

# prevent race conditions in creating the input files
if mkdir "read_sets_changed.started";
then
    zcat sim_"${LENGTH_READS}"bp_"${READ_RATIO}"_"${AMOUNT}"_1.fq.gz >forward.changed.fq
    zcat sim_"${LENGTH_READS}"bp_"${READ_RATIO}"_"${AMOUNT}"_2.fq.gz >reverse.changed.fq

    # generate quality information
    /tank/projects/benchmark/benchmark/docker/benchmark-baseimage/random_qual.pl forward.changed.fq
    /tank/projects/benchmark/benchmark/docker/benchmark-baseimage/random_qual.pl reverse.changed.fq

    # prepare beacons
    touch forward.fq
    touch reverse.fq
    touch read_sets_changed.done

else
    date +"[%Y-%m-%d %H:%M:%S] Waiting for finishing of read preparation by other task"

    while [ ! -e read_sets_changed.done ];
    do
	sleep 60
	date +"[%Y-%m-%d %H:%M:%S] Still waiting for other job to prepare reads..."
    done
    date +"[%Y-%m-%d %H:%M:%S] Other process prepared the reads"
fi

# prevent race conditions in creating the output folder
if mkdir "${REPLICATE}";
then
    cd "${REPLICATE}"
    ln -s ../forward.* ../re* .
    cd ..
    
    # prepare beacons
    touch "${REPLICATE}".prep.done

else
    date +"[%Y-%m-%d %H:%M:%S] Waiting for finishing of folder preparation by other task"

    while [ ! -e "${REPLICATE}".prep.done ];
    do
	sleep 60
	date +"[%Y-%m-%d %H:%M:%S] Still waiting for other job to prepare folder..."
    done
    date +"[%Y-%m-%d %H:%M:%S] Other process prepared the folder"
fi

date +"[%Y-%m-%d %H:%M:%S] Deleting older logs if existing..."
find $(dirname "${LOGBASE}") -type f -name "$(basename "${LOGBASE}")"'*' | xargs --no-run-if-empty --verbose rm
date +"[%Y-%m-%d %H:%M:%S] Cleaning older logs finished"

DOCKERCMD="docker run -v ${OUTPUTDIR}:/data -e NUMCPUS=${THREADS} --cpus ${THREADS} --workdir /data/${REPLICATE} --user $(id -u):$(id -g) --name ${NAME} -d ${DOCKERIMAGE}"

date +"[%Y-%m-%d %H:%M:%S] Starting container using command : '${DOCKERIMAGE}'"
DOCKERID=$(${DOCKERCMD})
date +"[%Y-%m-%d %H:%M:%S] Docker container ID: ${DOCKERID}"

while true
do
    date +"%Y%m%d-T-%H:%M:%S" >>${LOGBASE}.docker-stats.log;
    docker stats ${DOCKERID} --no-stream >>${LOGBASE}.docker-stats.log;

    date +"%Y%m%d-T-%H:%M:%S $(du --apparent-size --bytes -s ${OUTPUTDIR}/${REPLICATE}/${OUTFOLDER})" >>${LOGBASE}.du.log;

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

date +"[%Y-%m-%d %H:%M:%S] Removing output folder"
cp "${REPLICATE}"/"${OUTFOLDER}"/output.fa ${LOGBASE}.output.fa
rm -rf "${REPLICATE}"/"${OUTFOLDER}"

date +"[%Y-%m-%d %H:%M:%S] Finished benchmark"
