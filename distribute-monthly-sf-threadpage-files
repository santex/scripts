#!/usr/bin/perl -0
#021128
for (<*>) {
    open F,$_; $c=<F>; close F;
    $c =~ m#<BR>([12]\d\d\d)-(\d\d?)-\d\d?\s# or next;
    $y = $1; $m = $2; $m = "0$m" if $m=~/^\d$/;
    mkdir "$y$m" unless -d "$y$m";
    rename $_, "$y$m/$_";
}
   