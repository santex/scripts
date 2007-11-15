#!/usr/bin/perl

use POSIX qw(strftime);

BEGIN {
  $PROJ_DIR = "/home/steven/proj/spanel";
  $TARGET_DIR = "/home/steven/tmp";
}

# ---

use lib "$PROJ_DIR/lib/perl";
use Spanel;

chdir $PROJ_DIR or die "FATAL: Can't chdir to `$PROJ_DIR': $!\n";

my $rev = `bzr log -r -1 --line | cut -d: -f1`;
$rev > 0 or die "FATAL: Can't get revision number\n";
chomp($rev);

my $timestamp = strftime "%Y%m%d", localtime;
my $targetn = "spanel-$Spanel::VERSION-$timestamp-r$rev";
my $targetp = "$TARGET_DIR/$targetn";

system qq(bzr export $targetp && \
  cd $TARGET_DIR && \
  rm -f $targetn.tar.gz && \
  tar cfz $targetn.tar.gz $targetn && \
  ls -l $targetn.tar.gz);

