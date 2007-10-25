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

# this would be more appropriate as it excludes uncommited changes,
# but it's slooow. so we'll still use rsync for now:
#
#   chdir $PROJ_DIR or die "FATAL: Can't chdir to `$PROJ_DIR': $!\n";
#   bzr checkout . $targetp/ && \
#   cd $TARGET_DIR && rm -rf .bzr && \

system qq(rsync -a --del --exclude '*~' --exclude '.bzr' $PROJ_DIR/ $targetp/ && \
  cd $TARGET_DIR && \
  rm -f $targetn.tar.gz && \
  tar cfz $targetn.tar.gz $targetn && \
  ls -l $targetn.tar.gz);

