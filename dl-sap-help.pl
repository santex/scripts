#!/usr/bin/perl

# 040322 - mengambil "plain html" files dari sebuah dokumentasi SAP di help.sap.com

use LWP::Simple;
use File::Path;

sub sapurl($$) {
  my ($nodeid, $which) = @_;
  my ($n1, $nrest) = $nodeid =~ m#(..)(.+)#;
  "http://help.sap.com/$BOOKTITLE/helpdata/en/$n1/$nrest/$which.htm";
}

$BOOKTITLE = "-";

if (@ARGV != 1) {
  print <<_;
Usage: $0 <tree-frame-url>
Example: $0 http://help.sap.com/saphelp_47x200/helpdata/en/34/239739f4e38a2ce10000000a11402f/tree.htm
_
  exit 0;
}

$ARGV[0] =~ s#^http://help\.sap\.com/##s or die "FATAL: Not a SAP help URL\n";
$ARGV[0] =~ m#((?:saphelp_marketplace/)?[^/]+)/helpdata/en/([0-9a-f]{2})/([0-9a-f]{30})/#i or die "FATAL: Not a valid English SAP help URL\n";

$BOOKTITLE = $1;
$nodeid = "$2$3";

unless (-d $BOOKTITLE) { mkpath [$BOOKTITLE] or die "FATAL: Can't mkdir $BOOKTITLE/: $!\n" }

$url = sapurl($nodeid, "treedata");
unless ($treedata = get $url) {
  $url = sapurl($nodeid, "tree");
  $treedata = get $url or die "FATAL: Can't GET $url\n";
}

@nodes = ();
while ($treedata =~ m#parent\.gMenu\.Add\((?:true|false),\s*"([^"]*)",\s*"([0-9a-f]{2})/([0-9a-f]{30})/[^"]+",\s*(\d+),#ig) {
  push @nodes, {id => "$2$3", title => $1, level => $4};
}

die "FATAL: Couldn't find any nodes in tree.htm / treedata.htm. Complete dump of tree.htm / treedata.htm: \n$treedata\n" unless @nodes;

open F, ">$BOOKTITLE/nodes.txt";
print F map { "$_->{id}|$_->{level}|$_->{title}\n" } @nodes;
close F or die "FATAL: Can't write $BOOKTITLE/nodes.txt: $!\n";

open F, ">$BOOKTITLE/urls.txt";
print F map { sapurl($_->{id}, "frameset")."\n" } @nodes;
close F or die "FATAL: Can't write $BOOKTITLE/urls.txt: $!\n";

print <<_;
Done (${\(scalar @nodes)} nodes). Now do the following:

cd $BOOKTITLE; wget -p -nc -k -e 'robots=off' -U 'Mozilla/4.0 (compatible; MSIE 6.0b; Windows NT 5.0)' -i urls.txt
_
