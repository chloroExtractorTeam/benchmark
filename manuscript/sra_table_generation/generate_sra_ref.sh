#!/bin/bash

# Get the data from NCBI
for i in $(sed '1d' ../sets_re_runs.csv | tr -d '"' | cut -f 2 -d ","); do sra-stat --quick ${i}; done | tee sets_sra-info.txt

# Create a temporary file with combined information
perl -ne 'chomp; my ($id, $tag, $reads, $rest) = split(/\|/, $_); my ($readnumber, $basenumber, undef) = split(":", $reads); $h{$id}{reads}+=$readnumber; $h{$id}{bases}+=$basenumber; END{ foreach my $id (sort keys %h) { printf "%s\t%d\t%d\t%.0f\n", $id, $h{$id}{reads}, $h{$id}{bases}, ($h{$id}{bases}/$h{$id}{reads}/2); }}' sets_sra-info.txt >blub.txt

wget https://raw.githubusercontent.com/chloroExtractorTeam/benchmark/master/data/real/real_datasets.t

join blub.txt <( join <(awk -F"," '{printf "%s\t%s\n", $2,$3}' sets_re_runs.csv | sed '/Re-eval/d' | sort | tr -d '"') <(sort real_datasets.tsv))  | perl generate_tab.pl | tee ../sra_ref.tex
