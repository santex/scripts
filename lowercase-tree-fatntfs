#!/usr/bin/perl -l

# 021125. rename"A","a" doesn't work. musti pake trik rename dulu ke some
# other name, baru balikin lagi

use File::Find;

@ARGV = "." unless @ARGV;

finddepth sub {
    my $lc = lc; my $lc2; my $counter;
    #return unless $_ ne $lc;
    return unless ($_ eq uc and $_ ne $lc);
    do {
        $counter=2; $counter++ while (-e "$lc$counter");
        (rename $_,"$lc$counter" and rename "$lc$counter",$lc) 
        and print "$_ => $lc"
    }
}, @ARGV;
