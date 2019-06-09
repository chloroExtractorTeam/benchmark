#!/usr/bin/env perl
    
use strict;
use warnings;

my @dat = ();

while (<>)
{
   chomp;

   my @fields = split(/\s+/, $_);
   
   my ($sra, $reads, $bases, $readlen, $used, $genus, $epithet, $spotlen, $nt);

   $sra     = shift(@fields);
   $reads   = shift(@fields);
   $bases   = shift(@fields);
   $readlen = shift(@fields);
   $used    = shift(@fields);
   $genus   = shift(@fields);
   $nt      = pop(@fields);
   $spotlen = pop(@fields);
   $epithet = join(" ", @fields);
   
   my $taxon = '\textit{'.$genus." ".$epithet.'}';
   $sra = sprintf '\href{https://trace.ncbi.nlm.nih.gov/Traces/sra/?run=%s}{%s}', $sra, $sra;
   my $nt2 = $nt;
   $nt2 =~ s/_/\\_/g;
   $nt  = sprintf '\href{https://www.ncbi.nlm.nih.gov/nuccore/%s}{%s}', $nt, $nt2;

   push(@dat, join(" & ", $taxon, $sra, $nt, '\num{'.$reads.'}', '\num{'.$bases.'}', '\num{'.$readlen.'}', $used)." \\\\\n");
}

foreach (sort @dat)
{
   print $_;
}
