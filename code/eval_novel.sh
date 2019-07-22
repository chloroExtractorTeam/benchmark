#!/usr/bin/env bash

QRY=$1
NAME=$2
echo -ne "$NAME\t"

blastn -query $QRY -subject $QRY -outfmt  '7 qseqid sseqid pident length qstart qend sstart send sstrand slen qlen' | grep minus | awk '$3 == "100.00" ' | awk '$1 == $2' |   sort -nr -k 4,4 | sed -n 1p | awk  '{print $4, $11}' | tr "\n" "\t"

grep -c  "^>" $QRY


### for the simulated data 
#for i in */*/output.fa ; do echo -ne "$(dirname $(dirname $i))\t"  >> res.tsv ; ../evaluate_completeness.sh /home/maa62rb/sim/athaliana_chloro_sim/TAIR10_chrC.fas $i $(basename $(dirname $i)) >> res.tsv ; done

## for the real datsets 
#for i in */*/output.fa ; do dat=$(dirname $(dirname $i)); echo -ne "$dat\t"  >> res.tsv ; ../evaluate_completeness.sh ~maa62rb/real/references/$(cat /home/maa62rb/real/real_datasets.tsv   | grep $dat  | awk '{print $NF}').fa $i $(basename $(dirname $i)) >> res.tsv ; done
