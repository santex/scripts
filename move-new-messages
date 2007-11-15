#!/usr/bin/perl

#021007 - program ini dijalankan dari sisi server

use POSIX qw(strftime);

$MAILDIR = "/home/nshelter/users/steven";
chdir $MAILDIR or die "Can't chdir to `$MAILDIR': $!\n";

$counter = 1;
$time = strftime("%Y%m%d", localtime);
do { $tmpdir = "tmp.$time.$counter"; $counter++ } while (-e $tmpdir);
mkdir $tmpdir, 0755 or die "Can't mkdir `$tmpdir': $!\n";

chdir "new" or die "Can't chdir to `new': $!\n";
for (<*>) {
    rename $_,"../$tmpdir/$_";
}

$counter = 1;
chdir "..";
do { $dir = "new.$time.$counter"; $counter++ } while (-e $dir);
rename $tmpdir, $dir;
