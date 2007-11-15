#!/usr/bin/perl
$|++;

use Getopt::Long;

my ($cur_month, $cur_year) = (localtime)[4,5]; $cur_month++; $cur_year+=1900;
my $cur_period = sprintf "%04d%02d", $cur_year, $cur_month;
my $last_month = $cur_month-1;
my $last_year = $cur_year; do {$last_year--; $last_month=12} if $last_month==0;
my $last_period = sprintf "%04d%02d", $last_year, $last_month;

my $period_re = qr/^(?:(?:19|20)\d\d\d\d)(?:-(?:19|20)\d\d\d\d)?$/; # non-capture

$start = "190001";
$end = $cur_period;

GetOptions(
    "no-earlier-than|s=s" => \$start,
    "no-later-than|e=s" => \$end,
);

die "FATAL: Bad start period `$start'\n" unless $start =~ $period_re;
die "FATAL: Bad end period `$end'\n" unless $end =~ $period_re;

%filenames=();
%months=qw(Jan 01 Feb 02 Mar 03 Apr 04 May 05 Jun 06 Jul 07 Aug 08 Sep 09 Oct 10 Nov 11 Dec 12);
$current_file="";
$line=0;
$n=0;
while (<>) {
    $line++;
    #print "line $line\n" if $line % 1000 == 0;
    if (/^From .+? (?:\w+\s+)?(\w+),?\s+\d\d?\s+\d\d?:\d\d?(?::\d\d?)?\s+(\d\d\d\d)\s*$/ or
        #          dow  day   mon     year     hh   mm   ss  tz
        /^From .+? \w+, \d\d? (\w+) (\d\d\d\d) \d\d:\d\d:\d\d ([+-]?\d\d\d\d|\w+)$/) {
        $m = $months{ucfirst lc $1} or die "$ARGV:$line: unknown month `$month'!\n";
        $y = $2;
        $filename = "$y$m.mbox";
        
        $filename = "$start.mbox" if $filename lt "$start.mbox";
        $filename = "$end.mbox" if $filename gt "$end.mbox";
        
        if ($current_filename ne $filename) {
            print "$filename\n";
            open F, ">>$filename" or die "Can't open $filename: $!\n";
            $current_filename = $filename;
        }
        $n++;
    } elsif (/^From /) {
    	if ($n) {
    	    warn "WARN: Line $line: Invalid From_ line: $_";
    	    $_ = " $_";
    	} else {
    	    die "FATAL: Line $line: Can't parse first From_ line: $_";
    	}
    }
    print F $_;
}
