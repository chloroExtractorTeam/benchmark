#!/bin/bash
#SBATCH --cpus-per-task=8
#SBATCH --mem=24G

COV=$1
READLEN=$2
CHR=$3
if [ -z "${4}" ]; then 
    CIRCULAR=''
else 
    CIRCULAR='--circular-genome'
fi

SEGMENT=$((2 * $READLEN + 100))
REVPOS=$(($SEGMENT - $READLEN + 1))
PROPORTION=$(echo "scale=3; $COV / (2*$READLEN)" | bc -l)
SEED=91685

seqkit sliding --window $SEGMENT --step 1 --threads 8 TAIR10_chr${CHR}.fas | seqkit sample --threads 8 --proportion $PROPORTION --rand-seed $SEED | seqkit shuffle --threads 8 --rand-seed $SEED | seqkit split --by-part 2 --threads 8 -O chr${CHR}_${READLEN}_intermediate
seqkit seq --reverse --complement --threads 8 chr${CHR}_${READLEN}_intermediate/stdin.part_002.fasta >>chr${CHR}_${READLEN}_intermediate/stdin.part_001.fasta
seqkit shuffle --threads 8 --rand-seed 91685 --out-file chr${CHR}_${READLEN}_intermediate2.fa.gz chr${CHR}_${READLEN}_intermediate/stdin.part_002.fasta
rm -r chr${CHR}_${READLEN}_intermediate
seqkit subseq --region 1:${READLEN} --threads 8 --line-width 0 --out-file chr${CHR}_1.${READLEN}bp.${COV}x.fa chr${CHR}_${READLEN}_intermediate2.fa.gz
seqkit subseq --region ${REVPOS}:${SEGMENT} --threads 8 chr${CHR}_${READLEN}_intermediate2.fa.gz | seqkit seq --reverse --complement --line-width 0 --threads 8 --out-file chr${CHR}_2.${READLEN}bp.${COV}x.fa
rm -r chr${CHR}_${READLEN}_intermediate2.fa.gz
perl fasta_to_fastq.pl chr${CHR}_1.${READLEN}bp.${COV}x.fa >chr${CHR}_1.${READLEN}bp.${COV}x.fq
perl fasta_to_fastq.pl chr${CHR}_2.${READLEN}bp.${COV}x.fa >chr${CHR}_2.${READLEN}bp.${COV}x.fq
rm chr${CHR}_[12].${READLEN}bp.${COV}x.fa
