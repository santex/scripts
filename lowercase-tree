#!/usr/bin/perl -l

use File::Find;

@ARGV = "." unless @ARGV;

finddepth sub {
    my $lc = lc;
    return unless $_ ne $lc;
    do {rename $_,$lc and print "$_ => $lc"} unless -e $lc;
}, @ARGV;
