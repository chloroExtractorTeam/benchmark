#!/bin/bash

# first test for the input files
if [ ! -e forward.fq ]
then
    echo "Missing forward reads. Please add a file called forward.fq"
    exit 1;
fi

if [ ! -e reverse.fq ]
then
    echo "Missing reverse reads. Please add a file called reverse.fq"
    exit 1;
fi

# the number of CPUs can be specified using the environment variable NUMCPUS
: "${NUMCPUS:=4}"

echo "Number of CPUs/threads is set to ${NUMCPUS} and might be changed by defining NUMCPUS as environmental variable"

# Run the correct assembler based on the environment variable
if [ -n "$CHLOROEXTRACTORVERSION" ]
then
    echo "Running chloroExtractor"

    ptx -1 forward.fq -2 reverse.fq -d ptx --threads ${NUMCPUS}

    if [ -e ptx/fcg.fa ]
    then
	cp ptx/fcg.fa output.fa
    else
	touch output.fa
    fi
fi

if [ -n "$GETORGANELLEVERSION" ]
then
    echo "Running GetOrganelle"

    mkdir get_organelle
    cd get_organelle
    ln -s ../forward.fq
    ln -s ../reverse.fq
    get_organelle_reads.py -1 forward.fq -2 reverse.fq -o ./ -R 15 -k 21,45,65,85,105 -F plant_cp -t ${NUMCPUS}

    find -name "*path_sequence.fasta" | sort | head -1 | xargs -I{} cp {} ../output.fa
fi

if [ -n "$IOGAVERSION" ]
then
    echo "Running IOGA"

    REFERENCE="reference.fa"
    if [ ! -e ${REFERENCE} ]
    then
	echo "Missing reference file. Therefore, TAIR10 chloroplast is used internally."
	REFERENCE="/opt/reference.fa"
    fi

    IOGA.py --reference "${REFERENCE}" --forward forward.fq --reverse reverse.fq --threads ${NUMCPUS}

    cp IOGA_RUN.final/$(sed -n '2p' IOGA_RUN.final/IOGA_RUN.statistics | cut -f 1).fasta output.fa
fi

if [ -n "$NOVOPLASTYVERSION" ]
then
    echo "Running NOVOPlasty"

    mkdir novo_plasty
    cd novo_plasty

    REFERENCE="../reference.fa"
    if [ ! -e ${REFERENCE} ]
    then
	echo "Missing reference file. Therefore, TAIR10 chloroplast is used internally."
	REFERENCE="/opt/reference.fa"
    else
	ln -s ../reference.fa
    fi

    ln -s ../forward.fq
    ln -s ../reverse.fq

    # Estimate read length
    export NUMREADS=10000
    export READLEN=$(($(head -n $((${NUMREADS}*4)) forward.fq | sed -n '1~4{n;p}' | tr -d "\n" | wc -c)/${NUMREADS}))
    export INSERTSIZE=$((${READLEN}*23/10))

cat >config.txt <<EOF
Project:
-----------------------
Project name          = NOVOPlasty
Type                  = chloro
Genome Range          = 100000-250000
K-mer                 = 39
Max memory            =
Extended log          = 0
Save assembled reads  = no
Seed Input            = $REFERENCE
Reference sequence    =
Variance detection    = no
Heteroplasmy          =
HP exclude list       =
Chloroplast sequence  =

Dataset 1:
-----------------------
Read Length           = $READLEN
Insert size           = $INSERTSIZE
Platform              = illumina
Single/Paired         = PE
Combined reads        =
Forward reads         = forward.fq
Reverse reads         = reverse.fq

Optional:
-----------------------
Insert size auto      = yes
Insert Range          = 1.8
Insert Range strict   = 1.3
Use Quality Scores    = no
EOF

    NOVOPlasty.pl -c config.txt

    cp Circularized_assembly_1_NOVOPlasty.fasta ../output.fa
fi

if [ -n "$CHLOROPLASTASSEMBLYPROTOCOL" ]
then
    echo "Running chloroplast-assembly-protocol"

    mkdir chloroplastassemblyprotocol
    cd chloroplastassemblyprotocol

    REFERENCE="../reference.fa"
    if [ ! -e ${REFERENCE} ]
    then
	echo "Missing reference file. Therefore, TAIR10 chloroplast is used internally."
	REFERENCE="/opt/reference.fa"
    else
	ln -s ../reference.fa
    fi

    mkdir input
    cd input
    ln -s ../../forward.fq
    ln -s ../../reverse.fq
    cd ..

    0_get_cp_reads.pl input cp_noref $REFERENCE
fi

if [ -n "$FASTPLASTVERSION" ]
then
    echo "Running fast-plast"

    fast-plast.pl -1 forward.fq -2 reverse.fq -name fast-plast --threads ${NUMCPUS}

    cp $(find -name "*_FULLCP.fsa") output.fa
fi

if [ -n "$ORGASMVERSION" ]
then
    echo "Running ORG-asm"
fi
