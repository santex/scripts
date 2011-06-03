#!/usr/bin/perl

# 2004-12-18, di debian indexer = /usr/bin/index++
# 041017, add --delete-mbox-bz2. rename --delete-swish to --delete-index. remove --swish. comment out CHM report (we no longer have those).
# 040204, add --force option for --move-mbox & --hypermail, --no-backup option for --hypermail
# 031231, include php & phtml (pgsql-* mailing list archive from web)
# 030806, sort things to process
# 030425, i wrote this like 1-2 months ago, but the script must have got deleted :(
# 030601, add action=move-mbox
# 030702, add note that --move-mbox can only be done if hypermail dir is gone

my $ARCHIVE_ROOT = "/home/steven/p/archive";
my $MBOX_ARCHIVE_ROOT = "/home/steven/p/archive-mbox"; # tempat penyimpanan yang mbox.bz2
my $HYPERMAIL_SCRIPT = "/home/steven/bin/hypermail-all-mboxes.pl";
my $SWISH_INDEXER = "/usr/bin/index++";

###

$|++;
use strict;
use Getopt::Long;
use File::Path;
sub cmd($);

my ($cur_month, $cur_year) = (localtime)[4,5]; $cur_month++; $cur_year+=1900;
my $cur_period = sprintf "%04d%02d", $cur_year, $cur_month;
my $last_month = $cur_month-1;
my $last_year = $cur_year; do {$last_year--; $last_month=12} if $last_month==0;
my $last_period = sprintf "%04d%02d", $last_year, $last_month;

my $period_re = qr/^(?:(?:19|20)\d\d\d\d)(?:-(?:19|20)\d\d\d\d)?$/; # non-capture
my $period1_re = qr/^((?:19|20)\d\d\d\d)$/; # capture
my $period2_re = qr/^((?:19|20)\d\d\d\d)-((?:19|20)\d\d\d\d)$/; # capture
my $ng_re = qr/^[\w-]+(?:\.[\w-]+)+$/; # non-capture
my $list_re = qr/^.+\@.+$/; # non-capture

my $action = "stat";
my $start = "190001";
my $end = $last_period;
my $verbose = 0;
my $help = 0;
my $include_ng = 0;
my $include_list = 1;
my $dry = 0;
my $pattern;
my $pattern_re;
my $force = 0;
my $backup = 1;

GetOptions(
    "stat" => sub { $action="stat" },
    "hypermail" => sub { $action="hypermail" },
    "delete-hypermail" => sub { $action="delete-hypermail" },
    "delete-mbox-bz2" => sub { $action="delete-mbox-bz2" },
    "zip-hypermail" => sub { $action="zip-hypermail" },
    "unzip-hypermail" => sub { $action="unzip-hypermail" },
    "delete-zip" => sub { $action="delete-zip" },
    "delete-index" => sub { $action="delete-index" },
    "index" => sub { $action="index" },
    "move-mbox" => sub { $action="move-mbox" },
    
    "group-pattern|pattern|p=s" => \$pattern,
    "no-earlier-than|s=s" => \$start,
    "no-later-than|e=s" => \$end,
    "help" => sub { $help=1 },
    "nolist" => sub { $include_list=0 },
    "ng" => sub { $include_ng=1 },
    "onlylist" => sub { $include_list=1; $include_ng=0 },
    "onlyng" => sub { $include_list=0; $include_ng=1 },
    "both" => sub { $include_list=1; $include_ng=1 },
    "dry-run|dry" => sub { $dry=1 },
    "force" => sub { $force=1 },
    "no-backup" => sub { $backup=0 },
);

if (!$pattern) { $pattern = $ARGV[0] || ".*"; }

die "FATAL: Bad start period `$start'\n" unless $start =~ $period_re;
die "FATAL: Bad end period `$end'\n" unless $end =~ $period_re;
die "FATAL: Bad pattern `$pattern': $@\n" if [eval {$pattern_re = qr/$pattern/i}, $@]->[-1]; 

if ($help) {
    print <<_;
Usage:
  manage-archive.pl <ACTION> [OPTIONS]
  manage-archive.pl <--help | -h>

Actions:
  --hypermail
    Generate hypertext archive of monthly mailboxes (YYYYMM.mbox) using
    hypermail. Produces a directory of HTML files (YYYYMM/) and backup of
    mailbox (YYYYMM.mbox.bz2). Deletes YYYYMM.mbox if succeeds. Do nothing
    if YYYYMM/ already exists. Won't produce *.mbox.bz2 if --no-backup is
    specified.

  --delete-hypermail
    Delete the directory of HTML files (YYYYMM/).
    
  --zip-hypermail
    Produce YYYYMM.zip from YYYYMM/ directory. Do nothing if YYYYMM.zip
    already exists.
  
  --unzip-hypermail
    Produce YYYYMM/ from YYYYMM.zip. Do nothing if YYYYMM/ already exists.

  --delete-zip
    Delete YYYYMM.zip
    
  --delete-mbox-bz2
    Delete YYYYMM.zip
    
  --delete-index
    Delete YYYYMM.index

  --index
    Create a monthly index (YYYYMM.index) from directory of HTML files
    (YYYYMM/) using SWISH++. Do nothing if YYYYMM.index already exists.
  
  --stat
    Show statistics.

  --move-mbox
    Move *.mbox.bz2 files from archive dir to mbox archive dir (will only
    move if there are no corresponding hypermail dir, unless --force is
    specified).
    
Options:
  -s YYYYMM
    Earliest period to process. Default is 190001.
  -e YYYYMM
    Latest period to process. Default is last month.
  --ng
    Include newsgroups. Default is only mailing list (*\@*).
  --nolist
    Exclude mailing lists.
  --dry-run, --dry
    Only show what commands are to be executed without actually executing
    them.
  --force
    For --move-mbox, move *.mbox.bz2 even if the corresponding *.mbox still
    exists. For --hypermail, run hypermail even if the corresponding
    hypermail dir already exists.
  --no-backup
    For --hypermail, don't create .mbox.bz2 files.
_

    exit 0;
}

chdir $ARCHIVE_ROOT or die "FATAL: Can't chdir to archive root ($ARCHIVE_ROOT): $!\n";

my %N; my %DU;
%N = %DU = (
    Lists => 0,
    Newsgroups => 0,
    Entries => 0,
    chm => 0,
    mbox => 0,
    mboxbz2 => 0,
    mboxbak => 0,
    index => 0,
    dir => 0,
    zip => 0,
);

for my $prefix (sort <?>) {
    chdir $prefix or die "FATAL: Can't chdir to prefix $prefix: $!\n";
    
    ENTRY: for my $entry (sort <*>) {
        next if $entry =~ /~$/;
        my $basename = $entry; $basename =~ s/\.(index|\d\d\d\d-\d\d\d\d\.chm|\d\d\d\d\.chm|chm)$//i if -f $entry;
        next unless $basename =~ $pattern_re;
        
        (-d $entry) and do {
            next ENTRY if $entry =~ $list_re && !$include_list;
            next ENTRY if $entry =~ $ng_re && !$include_ng;
            next unless $entry =~ $list_re || $entry =~ $ng_re;

            print "$prefix/$entry/\n";
            my $du = 0;#`du -sb $entry`+0;
            do {$N{Lists}++; $DU{Lists}+=$du} if $entry =~ $list_re;
            do {$N{Newsgroups}++; $DU{Newsgroups}+=$du} if $entry =~ $ng_re;
            
            next ENTRY if $action =~ /^(stat)$/;
            
            my %entries = ();
            chdir $entry or die "Can't chdir to $prefix/$entry: $!\n";
            for my $entry2 (<*>) {
                next if $entry2 =~ /~$/;
                my $basename2 = $entry2; $basename2 =~ s/\.(mbox|mbox\.gz|mbox\.bz2|zip)$//i if -f $entry2;
                next unless $basename2 =~ $period_re;

                $basename2 =~ $period1_re && ($1 lt $start || $1 gt $end) && next;
                $basename2 =~ $period2_re && ($1 lt $start || $2 gt $end) && next;
                $action eq 'hypermail' && (-f "$basename2.mbox") && ($force || (!(-d $basename2))) && $entries{"$basename2.mbox"}++;
                $action eq 'index' && (-d $basename2) && (!(-f "$basename2.index")) && $entries{"$basename2"}++;
                $action eq 'delete-hypermail' && (-d $basename2) && $entries{$basename2}++;
                $action eq 'delete-zip' && (-f "$basename2.zip") && $entries{"$basename2.zip"}++;
                $action eq 'delete-mbox-bz2' && (-f "$basename2.mbox.bz2") && $entries{"$basename2.mbox.bz2"}++;
                $action eq 'delete-index' && (-f "$basename2.index") && $entries{"$basename2.index"}++;
                $action eq 'zip-hypermail' && (-d $basename2) && (!(-f "$basename2.zip")) && $entries{$basename2}++;
                $action eq 'unzip-hypermail' && (-f "$basename2.zip") && (!(-d $basename2)) && $entries{"$basename2.zip"}++;
                $action eq 'move-mbox' && (-f "$basename2.mbox.bz2") && ($force || (!(-d $basename2))) && $entries{"$basename2.mbox.bz2"}++;
            }
            do {chdir ".."; next ENTRY} unless keys %entries;
            my $entries = join " ", map {"'$_'"} sort keys %entries;
            
            $du = `du -sbc $entries|tail -n1`+0;
            $N{Entries} += keys %entries; $DU{Entries} += $du;
            
            print "entries = $entries\n";
            if ($action eq 'hypermail') {
                my $hypermail_options = join " ", (
                  ($backup ? "" : "--nobak"),
                );
                cmd "$HYPERMAIL_SCRIPT $hypermail_options $entries && rm $entries";
                $N{mbox} += keys %entries; $DU{mbox} += $du;
            } elsif ($action eq 'index') {
                cmd "for p in $entries; do echo Indexing \$p/...; $SWISH_INDEXER -v1 -e 'html:*.htm*' -e 'html:*.php*' -e 'html:*.shtml' -e 'html:*.phtml' -i \$p.index \$p/; done";
                $N{dir} += keys %entries; $DU{dir} += $du;
            } elsif ($action eq 'zip-hypermail') {
                cmd "for p in $entries; do echo Zipping \$p/...; zip -rq \$p.zip \$p/; done";
                $N{dir} += keys %entries; $DU{dir} += $du;
            } elsif ($action eq 'unzip-hypermail') {
                cmd "for p in $entries; do unzip -q \$p; done";
                $N{zip} += keys %entries; $DU{zip} += $du;
            } elsif ($action eq 'delete-hypermail') {
                cmd "rm -r $entries";
                $N{dir} += keys %entries; $DU{dir} += $du;
            } elsif ($action eq 'delete-zip') {
                cmd "rm $entries";
                $N{zip} += keys %entries; $DU{zip} += $du;
            } elsif ($action eq 'delete-mbox-bz2') {
                cmd "rm $entries";
                $N{zip} += keys %entries; $DU{mboxbz2} += $du;
            } elsif ($action eq 'delete-index') {
                cmd "rm $entries";
                $N{index} += keys %entries; $DU{index} += $du;
            } elsif ($action eq 'move-mbox') {
                mkpath(["$MBOX_ARCHIVE_ROOT/$prefix/$entry"], 0, 0755) unless
                    (-d "$MBOX_ARCHIVE_ROOT/$prefix/$entry");
                cmd "mv $entries '$MBOX_ARCHIVE_ROOT/$prefix/$entry/'";
                $N{mboxbz2} += keys %entries; $DU{mboxbz2} += $du;
            }
            chdir "..";
        };
    }
    
    chdir "..";
}

# report
print <<_;

Reports
=======
Lists = $N{Lists}
Newsgroups = $N{Newsgroups}
Processed Entries = $N{Entries}

Processed:
mboxbz2 files = $N{mboxbz2} ($DU{mboxbz2} bytes)
mbox files = $N{mbox} ($DU{mbox} bytes)
mbox backup files = $N{mboxbak} ($DU{mboxbak} bytes)
hypermail dirs = $N{dir} ($DU{dir} bytes)
index files = $N{index} ($DU{index} bytes)
zip files = $N{zip} ($DU{zip} bytes)
_

###

sub cmd($) {
    print "CMD: $_[0]\n";
    system $_[0] unless $dry;
}
