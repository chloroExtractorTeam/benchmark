#!/usr/bin/env perl

use strict;
use warnings;

my %dat = ();

while (<>)
{
    chomp;
    my @fields = split(/\t/, $_);

    next unless (defined $fields[1] && $fields[1] && $fields[1] eq "ogdraw");

    # get the sequence ID
    $fields[0] =~ /^(\S+)--organism/;

    my $set = { id => $1 };

    # get the coords
    $set->{start} = $fields[3]+0;
    $set->{end}   = $fields[4]+0;

    # get the type
    # ;gbkey=repeat_region;Note=inverted_repeat_B_(IRB)%2C
    $fields[8] =~ /gbkey=([^;]+)/;
    $set->{key} = $1;
    $fields[8] =~ /Note=([^;]+?)%2C/;
    $set->{note} = $1;
    $set->{note} =~ s/_/ /g;
    
    push(@{$dat{$set->{id}}}, \%{$set});
}

foreach my $key (keys %dat)
{
    printf ">Feature %s\n", $key;
    foreach my $set (@{$dat{$key}})
    {
	printf "%d\t%d\t%s\n\t\t\t%s\t%s\n", $set->{start}, $set->{end}, $set->{key}, "note", $set->{note};
    }
}
