#!/usr/bin/perl

$|++;
for $f (@ARGV) {
    open F, $f or do {warn "Can't open $f: $!\n"; next};
    $n = 0;
    while (<F>) { $n++ if /^From / }
    print "$f: $n\n";
    close F;
}
