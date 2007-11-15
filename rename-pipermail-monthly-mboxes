#!/usr/bin/perl -l

#021002

%months = qw(
    jan 01 january 01
    feb 02 february 02
    mar 03 march 03
    apr 04 april 04
    may 05
    jun 06 june 06
    jul 07 july 07
    aug 08 august 08
    sep 09 september 09
    oct 10 october 10
    nov 11 november 11
    dec 12 december 12
);

$months = join "|", keys %months;
for(<*>) {
    if (/^((?:19|20)?\d\d)-($months)|(?:\.(?:mbo?x|txt))?$/i) {
        $old = $_;
        $year = $1; $month = lc $2;
        if (length($year) == 2) {
            $year = ($year > 37 ? "19":"20") . $month;
        }
        $new = "$year$months{$month}.mbox";
        print "$old -> $new";
        rename $old, $new;
    }
}