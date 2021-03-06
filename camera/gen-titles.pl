#!/usr/bin/perl

$|++;
for $year (grep {(-d) and /^(19|20)\d\d$/} <*>) {
    chdir $year or die "Can't chdir to $year: $!\n";
    for $dir (grep {(-d) and /^\d{8}(-[A-Za-z])?$/} <*>) {
        chdir $dir or die "Can't chdir to $year/$dir: $!\n"; 
        do {chdir "..";next} if -f "titles.txt";
        print "+ $dir...\n";
        open F,">titles.txt";
        print F "[enter album title here]\n";
        for (grep {/\.jpg$/i and not /\.tn\./i} <*>) {
            print F "$_:\n";
        }
        close F or die "Can't write titles.txt: $!\n";
        chdir ".." or die "Can't chdir back: $!\n";
    }
    chdir ".." or die "Can't chdir back: $!\n";
}
