#!/usr/bin/env perl

use strict;
use warnings;

use JSON;
use DateTime::Format::DateParse;

use Bio::SeqIO;
use Digest::MD5;

my $inputdir = shift;
my $prog     = shift;
my $threads  = shift;
my $seq_len  = shift;
my $ratio    = shift;
my $amount   = shift;
my $replica  = shift;

# build basename
my $basename  = ( length($inputdir) > 0 ) ? $inputdir."/" : "";
$basename    .= join("_", ($prog, $threads, $seq_len, $ratio, $amount, $replica));

print STDERR "Searching for following basename: '$basename'\n";

my ($start_time, 
    $end_time, 
    $overall_runtime, 
    $cpu_time, 
    $peak_cpu_usage, 
    $peak_memory, 
    $peak_disk_usage, 
    $exit_code,
    $num_contigs,
    $total_seq_length,
    $md5
    )=(
    "", 
    "", 
    0,
    0,
    0,
    0,
    0, 
    "",
    0,
    0,
    "-");

# get the overall runtime from .json file
my $filename = $basename.".json";
if (-e $filename)
{
    my $json = get_json($filename);

    $start_time      = DateTime::Format::DateParse->parse_datetime( $json->[0]{State}{StartedAt} );
    $end_time        = DateTime::Format::DateParse->parse_datetime( $json->[0]{State}{FinishedAt} );
    $overall_runtime = $end_time->epoch() - $start_time->epoch();
    $exit_code       = $json->[0]{State}{ExitCode};
}

# get the CPU-usage and Memory from .stats.json file
$filename = $basename.".stats.json";
if (-e $filename)
{
    my $json = get_json($filename, 1);

    foreach (@$json)
    {
	if (exists $_->{cpu_stats}{cpu_usage}{total_usage} && $_->{cpu_stats}{cpu_usage}{total_usage} > $cpu_time)
	{
	    $cpu_time = $_->{cpu_stats}{cpu_usage}{total_usage};
	}

	if (exists $_->{memory_stats}{max_usage} && $_->{memory_stats}{max_usage} > $peak_memory)
	{
	    $peak_memory = $_->{memory_stats}{max_usage};
	}
    }

    for(my $i=1; $i<@$json; $i++)
    {
	my $start_time = DateTime::Format::DateParse->parse_datetime( $json->[$i-1]{read} );
	my $end_time   = DateTime::Format::DateParse->parse_datetime( $json->[$i]{read} );
	my $time_delta = $end_time->epoch() - $start_time->epoch();

	my $old_cpu    = $json->[$i-1]{cpu_stats}{cpu_usage}{total_usage};
	my $new_cpu    = $json->[$i]{cpu_stats}{cpu_usage}{total_usage};
	my $cpu_delta  = abs($old_cpu - $new_cpu)/1000000000;

	my $mean_cpu   = sprintf("%.1f", ($cpu_delta/$time_delta*100));
	
	if ($mean_cpu > $peak_cpu_usage)
	{
	    $peak_cpu_usage = $mean_cpu;
	}
    }

    $cpu_time = sprintf("%.0f", $cpu_time = $cpu_time/1000000000);
}

# get the disk usage from .du.log file
$filename = $basename.".du.log";
if (-e $filename)
{
    open(FH, "<", $filename) || die "Unable to open file '$filename': $!\n";
    while(<FH>)
    {
	# line format is this:
	# timestamp           size_bytes  path
	# 20190510-T-14:25:34 8234        /home/bla/blub/sim_250bp/1000/2.5M//2/org-asm
	chomp;
	my ($timestamp, $size, $path) = split(/\s+/, $_, 3);
	if (defined $size && $size ne "" && ($size > $peak_disk_usage))
	{
	    $peak_disk_usage = $size;
	}
    }
    close(FH) || die "Unable to close file '$filename': $!\n";
}

# get the sequence information from .output.fa file
$filename = $basename.".output.fa";
if (-e $filename)
{
    my @seqs_for_md5 = ();

    my $inseq = Bio::SeqIO->new(-file => $filename);
    while (my $entry = $inseq->next_seq) {
	$num_contigs++;
	my $seq = $entry->seq();
	$seq = $entry->revcom() if ($entry->revcom() lt $seq);
	$seq =~ s/\s//g;
	$total_seq_length += length($seq);
	push(@seqs_for_md5, $seq);
    }

    # sort the returned sequences by alphabet and add a newline at the end
    @seqs_for_md5 = map { $_."\n" } sort { $a cmp $b } (@seqs_for_md5);
    # get the md5
    $md5 = Digest::MD5->new;
    $md5->add(@seqs_for_md5);
    $md5 = $md5->hexdigest();
}

if ($overall_runtime)
{
    print join("\t",
	       (
		"#program",
		"threads",
		"seq_len",
		"ratio",
		"amount",
		"iteration_num",
		"start_time",
		"end_time",
		"exit_code",
		"run_time_sec",
		"cpu_time_sec",
		"cpu_usage_percent",
		"peak_cpu_usage_percent",
		"peak_memory_bytes",
		"peak_disk_usage_bytes",
		"num_contigs",
		"total_seq_length_bp",
		"md5sum"
	       )
	), "\n",join("\t",
		     (
		      $prog, 
		      $threads, 
		      $seq_len, 
		      $ratio, 
		      $amount, 
		      $replica, 
		      $start_time, 
		      $end_time, 
		      $exit_code, 
		      $overall_runtime, 
		      $cpu_time, 
		      sprintf("%.1f", $cpu_time/$overall_runtime*100), 
		      $peak_cpu_usage, 
		      $peak_memory,
		      $peak_disk_usage,
		      $num_contigs,
		      $total_seq_length,
		      $md5
		     )
	), "\n";
}

sub get_json
{
    my ($filename, $linewise) = @_;

    open(FH, "<", $filename) || die "Unable to open file '$filename': $!\n";
    my @lines = <FH>;
    my $json = [];
    if (! defined $linewise || $linewise == 0)
    {
	@lines=(join("", @lines));
    }
    
    foreach (@lines)
    {
	my $new_json = decode_json($_);
	push(@$json, $new_json);
    }
    
    close(FH) || die "Unable to close file '$filename': $!\n";

    return $json;
}
