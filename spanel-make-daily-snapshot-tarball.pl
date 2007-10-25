#!/usr/bin/perl

use POSIX qw(strftime);

BEGIN {
  $PROJ_DIR = "/home/steven/proj/spanel";
  $TARGET_DIR = "/home/steven/tmp";
}

# ---

use lib "$PROJ_DIR/lib/perl";
use Spanel;

my $timestamp = strftime "%Y%m%d", localtime;
my $targetn = "spanel-$Spanel::VERSION-$timestamp";
my $targetp = "$TARGET_DIR/$targetn";

system qq(rsync -a --del --exclude '*~' --exclude '.bzr' $PROJ_DIR/ $targetp/ && \
  cd $TARGET_DIR && \
  rm -f $targetn.tar.gz && \
  tar cfz $targetn.tar.gz $targetn && \
  ls -l $targetn.tar.gz);

