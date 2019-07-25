#!/usr/bin/env bash

QRY=$1
NAME=$2
echo -ne "$NAME\t"

blastn -query $QRY -subject $QRY -outfmt  '7 qseqid sseqid pident length qstart qend sstart send sstrand slen qlen' | grep minus | awk '$3 ~ "100.00" ' | awk '$1 == $2' |   sort -nr -k 4,4 | sed -n 1p | awk  '{print $4, $11}' | tr "\n" "\t"

grep -c  "^>" $QRY

# Execute with : 
# for i in */*/output.fa ; do echo $i ;  echo -ne "$(dirname $(dirname $i))\t"  >> res.tsv ; ./eval_novel.sh  $i $(basename $(dirname $i)) >> res.tsv ; done
