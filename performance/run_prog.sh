#!/bin/bash

PROGRAM2CALL=$1
THREADS=$2
LENGTH_READS=$3
READ_RATIO=$4
AMOUNT=$5
REPLICATE=$6

VERSION=v1.0

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

EOF
