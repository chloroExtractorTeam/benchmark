#!/bin/bash

for i in $(ls ../dataset/athaliana_chloro_sim/subset/ | perl -ne 's/_[12]\.fq.gz\s*$//; $hash{$_}++; END{ foreach my $key (map {$_->{old}} sort { $a->{len} <=> $b->{len} || $a->{cov} <=> $b->{cov} || ($a->{amount}*$a->{factor}) <=> ($b->{amount}*$b->{factor})} map {$_ =~ /sim_(\d+)bp_(\d+)_([\d.]+)([MK])/; { old=>$_, len=>$1, cov => $2, amount => $3, factor => ($4 eq "K")?1000:1000000 }} (keys %hash)) {print $key,"\n";}}')
do
    DIR=$(echo $i | cut -f1,2 -d "_")/$(echo $i | cut -f3 -d "_")/$(echo $i | cut -f4 -d "_")
    mkdir -p "${DIR}"
    cd "${DIR}"
    ln -s ../../../../dataset/athaliana_chloro_sim/subset/"${i}"_1.fq.gz
    ln -s ../../../../dataset/athaliana_chloro_sim/subset/"${i}"_2.fq.gz
    ln -s ../../../main.nf
    ln -s ../../../nextflow.config
    cd -
done
