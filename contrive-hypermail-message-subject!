#!/usr/bin/perl -0 -pi
use FindBin qw($Bin);
require "$Bin/func-contrive-subject.pl";
#print STDERR "$ARGV\n";
s#<title([^>]*)>(.+)</title>#"<title$1>".contrive_subject($2)."</title>"#ei;
