#!/usr/bin/perl

# 021226 - dedicated especially for the incompetent list archive
# administrator at mail.kde.org (who creates mbox files without From_ lines.
# yes, he/she does!)

$id = 1;
$msg = "";
$prevempty = 0;
while (<>) {
    if (/^Received: / and $prevempty) {
        writemsg($msg) if $msg =~ /\S/;
        $msg = $_; $id++;
    } else {
        $msg .= $_;
    }
    $prevempty = /\S/ ? 0:1;
}

writemsg($msg) if $msg =~ /\S/;

sub writemsg($) {
    my $msg = shift;
    my $counter = 0;
    my $filename;
    
    while (1) {
        $filename = $counter ? "$id.msg.$counter" : "$id.msg";
        last unless -e $filename;
        $counter++;
    }
    print "$filename\n";
    open F, ">$filename";
    print F $msg;
    close F;
}
