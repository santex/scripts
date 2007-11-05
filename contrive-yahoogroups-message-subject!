#!/usr/bin/perl -0777 -pi
use FindBin qw($Bin);
require "$Bin/func-contrive-subject.pl";
s#<title([^>]*)>(.+)</title>#"<title$1>".contrive_subject($2)."</title>"#e;
