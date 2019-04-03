#!/bin/bash

if [ -z "$CHLOROEXTRACTORVERSION" ]
then
    echo "Running chloroExtractor"
fi

if [ -z "$GETORGANELLEVERSION" ]
then
    echo "Running GetOrgranelle"
fi

if [ -z "$IOGAVERSION" ]
then
    echo "Running IOGA"
fi

if [ -z "$NOVOPLASTYVERSION" ]
then
    echo "Running NOVOPlasty"
fi

if [ -z "$CHLOROPLASTASSEMBLYPROTOCOL" ]
then
    echo "Running chloroplast-assembly-protocol"
fi

if [ -z "$FASTPLASTVERSION" ]
then
    echo "Running fast-plast"
fi

if [ -z "$ORGASMVERSION" ]
then
    echo "Running ORG-asm"
fi
