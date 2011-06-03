#!/usr/bin/perl

# split mbox into smaller mboxes (with each containing a max of N
# messages) or individual messages (if N=1). will output to 1.mbox,
# 2.mbox and so on (or 1.msg, 2.msg, and so on if N=1). will create
# suffix ".1" and so on if existing files exist.

use warnings;
use strict;
use App::Options (
  option => {
    n => {
      description => "Maximum number of messages",
      default => 1,
      type => "integer",
      required => 0,
    },
  }
);

my $Id = 1;
my $n = $App::options{n};
my $Ext = $n == 1 ? "msg" : "mbox";
my $i = 0;

my @lines = ();
while (<>) {
  if (/^From / && @lines) {
    $i++;
    if ($i >= $n) {
      writefile(\@lines);
      @lines = (); $i = 0; $Id++;
    }
  }
  push @lines, $_;
}

writefile(\@lines) if @lines;

sub writefile {
  my $lines = shift;
  my $counter = 0;
  my $filename;
  local *F;

  shift @$lines if $n==1; # strip From line for single message file
  while (1) {
    $filename = $counter ? "$Id.$Ext.$counter" : "$Id.$Ext";
    last unless -e $filename;
    $counter++;
  }
  print "$filename\n";
  open F, ">$filename";
  print F @$lines;
  close F;
}
