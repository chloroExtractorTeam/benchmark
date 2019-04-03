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
    echo "Running GetOrgranelle"
fi

if [ -n "$IOGAVERSION" ]
then
    echo "Running IOGA"
fi

if [ -n "$NOVOPLASTYVERSION" ]
then
    echo "Running NOVOPlasty"
fi

if [ -n "$CHLOROPLASTASSEMBLYPROTOCOL" ]
then
    echo "Running chloroplast-assembly-protocol"
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
