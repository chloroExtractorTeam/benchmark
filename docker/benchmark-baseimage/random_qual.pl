#!/usr/bin/env perl

use strict;
use warnings;

my $filename = shift;

unless (defined $filename && -e $filename)
{
    print STDERR "Need to provide a filename as first argument\n";
    exit 1;
}

my $offset = shift;
if (! defined $offset || $offset !~ /^\d+$/)
{
    print STDERR "No offset or not-a-number is provided as second argument, therefore 33 is assumed\n";
    $offset = 33;
}

srand(20200411);

my @set = map { chr($offset+$_) } (0..41);

my $number2change = 10;

open(FH, "+<", $filename) || die "$!\n";
for(my $i=0; $i<$number2change; $i++)
{
    my $header  = <FH>;
    my $seq     = <FH>;
    my $header2 = <FH>;
    my $qual    = <FH>;

    my $pos = tell(FH) || die "$!\n";
    my $new_pos = $pos - length($qual);
    seek(FH, $new_pos, 0) || die "Unable to seek in file: $!\n";

    chomp($qual);
    my $len_req = length($qual);
    my @qualset = ();
    my $index = 0;
    while (@qualset < $len_req)
    {
	push(@qualset, $set[$index]);
	$index++;
	$index = 0 if ($index >= @set);
    }

    fisher_yates_shuffle(\@qualset);
    $qual = join("", @qualset)."\n";
    
    print FH $qual;
}
close(FH) || die "$!\n";

sub fisher_yates_shuffle {
    my $deck = shift;  # $deck is a reference to an array
    return unless @$deck; # must not be empty!
    my $i = @$deck;
    while (--$i) {
	my $j = int rand ($i+1);
	@$deck[$i,$j] = @$deck[$j,$i];
    }
}
