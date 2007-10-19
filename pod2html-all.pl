#!/usr/bin/perl

use File::Find;
use File::Path;

$source="/usr/lib/perl5";
$target="/home/steven/p/man/perl/pod";


finddepth sub {
  next unless -f && /(\.pod|\.pm)$/i;
  open F,$_ or warn "$0: $_: $!\n";
  mkpath(["$target/$File::Find::dir"], 0, 0711);
  system "pod2html $_ >$target/$File::Find::name.html";
}, $source;
