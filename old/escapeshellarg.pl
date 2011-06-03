#!/usr/bin/perl

# DEPRECATED: gak perlu lagi. bash punya "$@" (as well as "$*"). dengan
# "$@", tiap argumen udah diseparate dan diquote.

for (@ARGV) {
  print escapeshellarg($_), "\n";
}

sub escapeshellarg {
  local $_=shift;
  s/'/'"'"'/g;
  "'$_'";
}
