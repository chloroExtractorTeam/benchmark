#!/bin/bash
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G

for i in $(cut -f1 real_datasets.tsv)
do
	echo $i
	fasterq-dump --progress --threads 8 --split-files $i
	seqkit sample --threads 8 --two-pass --rand-seed 91685 --number 2000000 ${i}_1.fastq | seqkit shuffle --threads 8 --rand-seed 91685 --out-file ${i}_1.2M.shuf.fq.gz
	seqkit sample --threads 8 --two-pass --rand-seed 91685 --number 2000000 ${i}_2.fastq | seqkit shuffle --threads 8 --rand-seed 91685 --out-file ${i}_2.2M.shuf.fq.gz
	rm ${i}_1.fastq ${i}_2.fastq 
done
