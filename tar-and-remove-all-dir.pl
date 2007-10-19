#!/usr/bin/perl -l

# 2004-08-13 - tar all dirs into DIRNAME.tar and remove the dirs.

for (grep {-d} <*>) {
  if (-f "$_.tar") {
    print "WARNING: $_.tar exists, skipped";
  }
  $esc = esc($_);
  $cmd = "tar cf $esc.tar $esc && rm -r $esc";
  print $cmd;
  system $cmd;
}

sub esc {
  local $_ = shift;
  s/'/'"'"'/g;
  "'$_'";
}
