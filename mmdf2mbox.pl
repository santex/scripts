#!/usr/bin/perl -0777 -n

use POSIX qw(strftime);

while (/\001\001\001\001(.+?)\001\001\001\001/sg) {
    my $msg = $1;
    $msg =~ s/^From />From /mg;
    print strftime "From mmdf2mbox\@localhost %a %d %b %H:%M:%S %Y", localtime;
    print $msg;
    print "\n\n";
}
