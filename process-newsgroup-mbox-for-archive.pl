#!/usr/bin/perl

#021223

use Cwd;

my ($cur_date, $cur_month, $cur_year) = (localtime)[3,4,5]; $cur_month++; $cur_year+=1900;
my $cur_period = sprintf "%04d%02d", $cur_year, $cur_month;
my $last_month = $cur_month-1;
my $last_year = $cur_year; do {$last_year--; $last_month=12} if $last_month==0;
my $last_period = sprintf "%04d%02d", $cur_year, $last_month;

$|++;
$archive_dir = "/home/steven/p/archive";
$split_script = "/home/steven/bin/split-mbox-monthly.pl";

$cwd = getcwd;
for $mbox (<*.mbox>, <*.mbox.*>) {
    $mbox =~ /((.).*)\.mbox(.*)$/;
    $newsgroup = $1;
    $letterdir = lc($2) ge "a" && lc($2) le "z" ? lc($2) : "0";
    $newsgroupdir = "$archive_dir/$letterdir/$newsgroup";

    print "+ $mbox (news://$newsgroup)\n";
    if (not (-s $mbox)) { next } # { print "  size=0, skipped\n"; next }
    if (not (-e $newsgroupdir) and not mkdir $newsgroupdir,0755) { die "  failed mkdir `$newsgroupdir' ($!), exiting...\n" }
    chdir "$archive_dir/$letterdir/$newsgroup/" or die "  failed chdir `$newsgroupdir' ($!), exiting...\n";
    system "$split_script -e 200509 -s 200509 $cwd/$mbox"; die "  failed split ($?), exiting...\n" if $?;
    #system "$split_script -e $last_period -s $last_period $cwd/$mbox"; die "  failed split ($?), exiting...\n" if $?;
    #system "$split_script -e $cur_period -s $cur_period $cwd/$mbox"; die "  failed split ($?), exiting...\n" if $?;
    chdir $cwd;
}
