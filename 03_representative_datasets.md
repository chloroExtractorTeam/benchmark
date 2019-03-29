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
