#!/usr/bin/perl

# 20040216

use URI::Escape;

sub escapeshellarg {
  local $_ = shift;
  s/'/'"'"'/g;
  "'$_'";
}

@cmds = ();
while (<>) {
  ($filename, $md5) = m#ed2k://\|file\|(.+?)\|\d+\|([0-9A-Fa-f]{32})\|# or next;
  push @cmds, "mv ~download/ml/temp/$md5 ${\(escapeshellarg uri_unescape $filename)}\n";
}

print @cmds;
