#!/usr/bin/perl -0
#030526

%months = qw(Jan 01 Feb 02 Mar 03 Apr 04 May 05 Jun 06
             Jul 07 Aug 08 Sep 09 Oct 10 Nov 11 Dec 12);

for (<*>) {
    open F,$_; $c=<F>; close F;
    $c =~ m#>&nbsp;<NOBR>(\w\w\w) \d\d?, (\d\d\d?\d?)# or next;
    $y = $2; $y += 2000 if $y < 10;
    $m = $months{$1} or do { warn "$_: unrecognized month `$1', skipped\n"; next };
    mkdir "$y$m" unless -d "$y$m";
    rename $_, "$y$m/$_";
}
   