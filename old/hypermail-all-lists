#!/usr/bin/perl

# 030302

$archivedir = "/home/steven/p/archive";

###

$|++;
use POSIX;
use Getopt::Long;

sub mysystem { print $_[0],"\n"; unless ($dry) { system $_[0]; die "system failed (\$?=$?), exiting...\n" if $? } }

$dry = 0;
$delete = 0;
$newsgroup = 0;
$list = 1;
$help = 0;
$nolastmonth = 0;
$minperiod = "";

GetOptions(
    "--help" => \$help,
    "--newsgroup" => sub { $newsgroup=1 },
    "--minperiod=s" => \$minperiod,
    "--nolist" => sub { $list=0 },
    "--nolastmonth" => sub { $nolastmonth=1 },
    "--delete" => sub { $delete=1 },
    "--dry" => sub { $dry=1 },
);

if ($help) {
    die <<_;
Usage: $0 [options]
Options:
--help              This message.
--newsgroup         Process newsgroups too.
--nolist            Don't process mailing lists.
--nolastmonth       Don't process last month's mbox too.
--delete            Delete instead of process.
--dry               Dry run (don't actually do anything).
--minperiod=YYYYMM  Don't process mbox earlier than this.
_
}

die "Invalid period: $minperiod\n" if $minperiod && $minperiod !~ /^\d{6}$/;

@lt = localtime;
$curmonth = POSIX::strftime "%Y%m", @lt;
$lt[4]--; if ($lt[4] == -1) { $lt[4] == 11; $lt[5]-- }
$lastmonth = POSIX::strftime "%Y%m", @lt;

$ntotal =  $bytestotal = 0;

chdir $archivedir or die "Can't chdir to archivedir `$archivedir': $!\n";
for $subdir ("a".."z","_") {
    chdir $subdir or die "Can't chdir to subdir `$subdir': $!\n";
    for $dir (grep {-d} <*>) {
        next if $dir !~ /\@/ && !$newsgroup;
        next if $dir =~ /\@/ && !$list;
        print "+ $dir\n";
        chdir $dir or die "Can't chdir to listdir `$subdir/$dir': $!\n";
        @mboxes = grep {(-f) && 
                        /^(\d{6}(?:-\d{6})?)\./ && 
                        ($delete || !(-d $1) && !(-f "$1.mbox.bz2")) &&                # mbox not backup up and/or archived yet
                        (!$minperiod || $1 ge $minperiod) &&                           # skip older months, optionally
                        $_ ne "$curmonth.mbox" && !/-$curmonth/ &&                     # skip current month
                        (!$nolastmonth || ($_ ne "$lastmonth.mbox" && !/-$lastmonth/)) # skip last month, optionally
                       } <*.mbox>;
        if (@mboxes) {
            $ntotal += @mboxes;
            $bytestotal += (-s $_) for @mboxes;

            if ($delete) {
                mysystem "rm ".join(" ",@mboxes);
            } else {
                mysystem "hyp ".join(" ",@mboxes);
            }
        }
        chdir "..";
    }
    chdir "..";
}

printf "Total mboxes = %d (%.1f MB)\n", $ntotal, $bytestotal/1024/1024;
