#!/usr/bin/env bash

REF=$1
QRY=$2
NAME=$3

minimap2 -a -N 5 -x asm5 --cs -c $REF $QRY | samtools view -Sb | samtools sort >${NAME}_vs_ref.bam
minimap2 -a -N 5 -x asm5 --cs -c $QRY $REF | samtools view -Sb | samtools sort >ref_vs_${NAME}.bam

echo -ne "$NAME\t"
bedtools genomecov -ibam ${NAME}_vs_ref.bam -bga | perl -ane '$l=$F[2]-$F[1];$t+=$l;$c+=$l if($F[3]>0);END{print "$t\t$c\t".($c/$t)}'
bedtools genomecov -ibam ref_vs_${NAME}.bam -bga | perl -ane '$l=$F[2]-$F[1];$t+=$l;$c+=$l if($F[3]>0);END{print "\t$t\t$c\t".($c/$t)."\t"}'
grep -c  "^>" $QRY

rm ${NAME}_vs_ref.bam 
rm ref_vs_${NAME}.bam


#for i in */*/output.fa ; do echo -ne "$(dirname $(dirname $i))\t" ; ../evaluate_completeness.sh /home/maa62rb/sim/athaliana_chloro_sim/TAIR10_chrC.fas $i $(basename $(dirname $i)) >> res.tsv ; done

