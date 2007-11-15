#!/usr/bin/perl
$|++;
while (<>) {
    chomp;
    @_ = split '', $_;
    print while defined($_ = splice @_, rand @_, 1);
    print "\n";
}
