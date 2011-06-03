#!/usr/bin/perl6

my Num $height = 12;

# rakudo belum support hyperop
#my Num @data = +<< @*ARGS;
my Num @data = map { +$_ }, @*ARGS;
die "Usage: pctbargraph <data ...>, e.g. 30 40 21 9" unless @data;
my Num $max = @data.max;
my Num $tot = [+] @data;
die "Zero or negative total" unless $tot > 0;

for 1..$height -> $line {
    say map {
        (($height-$line) <= (@data[$_] * $height/$max) ?? "##" !! "  ") ~ '  '
    }, 0..@data-1;
}

