perl -ane '/gene=(.*)/;$g=$1;$F[0]=~s/-.*//;print "$F[0]\t$F[2]\t$g\n" if $F[2] =~ /rRNA|tRNA|CDS/' *_GFF3.gff3 >features.tsv
Rscript feature_counts.R
