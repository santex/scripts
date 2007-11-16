#!/usr/bin/perl

# 030812

use URI::Escape;

system "which xurls.pl 2>&1 >/dev/null"; die "Can't find xurls.pl\n" if $?;
@ARGV == 1 or die "Usage: $0 <url>\n";
open X, "xurls.pl ${\( escapeshellarg($ARGV[0]) )} |";
while (<X>) {
  chomp;
  s/'/%27/g; m#.+/(.+)# and $name = $1 or $name = $_;
  print "[url=$_]",uri_unescape($name),"[/url]\n";
}

sub escapeshellarg { local $_ = shift; s/'/'"'"'/g; "'$_'" }
