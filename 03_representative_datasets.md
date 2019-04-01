# Select/design representative datasets
We use both simulated and real data.

- Simulated: "perfect" datasets from *Arabidopsis thaliana* using different read lengths (150 and 250) and differenct genome:chloroplast ratios (1:10, 1:100, 1:1000)
- Real: public, Illumina, paired, plant, DNA, random, wgs datasets from [SRA](https://www.ncbi.nlm.nih.gov/sra) where a reference chloroplast for the species is present in [CpBase](http://rocaplab.ocean.washington.edu/old_website/tools/cpbase)

## Simulated Data
Download reference *Arabidopsis thaliana* data from [TAIR](https://www.arabidopsis.org)

```bash
mkdir -p data/sim/athaliana
cd data/sim/athaliana
wget "ftp://ftp.arabidopsis.org/home/tair/home/tair/Sequences/whole_chromosomes/TAIR10_*.fas"
```

simulate 30x genome coverage and 300x mitochondrial coverage with 150bp and 250bp reads

```bash
for i in {1..5}; do simulate.sh 30 150 $i; done
for i in {1..5}; do simulate.sh 30 250 $i; done
for i in 150 250; do simulate.sh 300 $i M circular; done
```

simulate chloroplast reads with 150bp and 250bp at 300x and 500x coverage respectively

``` bash
simulate.sh 300 150 C circular
simulate.sh 500 250 C circular
seqkit sample --threads 8 --proportion 0.6 --rand-seed 91685 --out-file chrC_1.250bp.300x.fq chrC_1.250bp.500x.fq
seqkit sample --threads 8 --proportion 0.6 --rand-seed 91685 --out-file chrC_2.250bp.300x.fq chrC_2.250bp.500x.fq
```

Create datasets for 1:10, 1:100, 1:1000

```bash
cat chr{1,2,3,4,5}_1.150bp.30x.fq chrM_1.150bp.300x.fq >starter_1.150bp.fq
cat chr{1,2,3,4,5}_2.150bp.30x.fq chrM_2.150bp.300x.fq >starter_2.150bp.fq
cat chr{1,2,3,4,5}_1.250bp.30x.fq chrM_1.250bp.300x.fq >starter_1.250bp.fq
cat chr{1,2,3,4,5}_2.250bp.30x.fq chrM_2.250bp.300x.fq >starter_2.250bp.fq
for i in 1 2
do
    cat starter_${i}.150bp.fq chrC_${i}.150bp.300x.fq | seqkit shuffle --threads 8 --rand-seed 91685 --out-file sim_${i}.150bp.1-10.fq
    cat starter_${i}.250bp.fq chrC_${i}.250bp.300x.fq | seqkit shuffle --threads 8 --rand-seed 91685 --out-file sim_${i}.250bp.1-10.fq
    cat starter_${i}.150bp.fq $(yes chrC_${i}.150bp.300x.fq | head -n 10) | seqkit shuffle --threads 8 --rand-seed 91685 --out-file sim_${i}.150bp.1-100.fq
    cat starter_${i}.250bp.fq $(yes chrC_${i}.250bp.500x.fq | head -n 6) | seqkit shuffle --threads 8 --rand-seed 91685 --out-file sim_${i}.250bp.1-100.fq
    cat starter_${i}.150bp.fq $(yes chrC_${i}.150bp.300x.fq | head -n 100) | seqkit shuffle --threads 8 --rand-seed 91685 --out-file sim_${i}.150bp.1-1000.fq
    cat starter_${i}.250bp.fq $(yes chrC_${i}.250bp.500x.fq | head -n 60) | seqkit shuffle --threads 8 --rand-seed 91685 --out-file sim_${i}.250bp.1-1000.fq
done
```

## Real Data
Get list of plants with chloroplast in CpBase (incl accession):

```bash
mkdir -p data/real
cd data/real
curl http://rocaplab.ocean.washington.edu/old_website/tools/cpbase/run | egrep "href|(A|N)C_" | egrep "genome|(A|N)C_" | grep "td" | perl -pe 's/.*view=genome.>(.*)<\/a>.*\n/\1\t/;s/.*([NA]C_\d+)<.*/\1/' >cpbase.tsv
# The file contained in this repository was created on 2019-03-28

# Do a search at https://www.ncbi.nlm.nih.gov/sra with string:
# ((((((("green plants"[orgn]) AND "wgs"[Strategy]) AND "illumina"[Platform]) AND "biomol dna"[Properties]) AND "paired"[Layout]) AND "random"[Selection])) AND "public"[Access]
# Save results (RunInfo) as SraRunInfo_plants.csv
# The file contained in this repository was created on 2019-03-28

# For each species in both CpBase and SRA get the SRA-number with the highest avgLength:

csv2tsv SraRunInfo_plants.csv |
 perl -ne 'print unless /^$/' |
 tsv-select -f1,29,7 |
 sort -t $'\t' -k2,2 -k3,3nr |
 tsv-uniq -f 2 |
 tsv-join --filter-file cpbase.tsv --key-fields 1 --data-fields 2 --append-fields 2 --allow-duplicate-keys |
 tsv-sample --seed-value 91685 >real_datasets.tsv
```

Download reference chloroplasts
```
mkdir -p data/real/references
cd data/real/references
for i in $(cut -f4 ../real_datasets.tsv)
do
    ncbi-acc-download --format fasta $i
done
```

Download samples from SRA, shuffle and sample to (approx) 2M reads
```
download.sh
```

## Requirements
Used version in parentheses
 - [seqkit](https://github.com/shenwei356/seqkit) (v0.10.1): Shen W, Le S, Li Y, Hu F (2016) SeqKit: A Cross-Platform and Ultrafast Toolkit for FASTA/Q File Manipulation. PLOS ONE 11(10): e0163962. [https://doi.org/10.1371/journal.pone.0163962](https://doi.org/10.1371/journal.pone.0163962)
 - [tsv-utils](https://github.com/eBay/tsv-utils) (v1.3.2)
 - [sra-tools](https://github.com/ncbi/sra-tools) (2.9.6)
 - [ncbi-acc-download](https://github.com/kblin/ncbi-acc-download) (0.2.4)
