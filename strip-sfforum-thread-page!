#!/usr/bin/perl -0 -pi
#021201
s|.+?(<table BORDER="0"><tr> <td BGCOLOR="#DDDDDD" NOWRAP>By:)|$1|si;
s|<table WIDTH="100%" BORDER="0">\s+<tr BGCOLOR="#EEEEEE"><td WIDTH="50%">&nbsp;</td>.+||si;
($title) = m#<a href="/forum[^>]+>(?:<x?img[^>]+>)?(.+?)</a>#i; $title =~ s/^\s+//; $title =~ s/\s+$//;
s#<img#<ximg#ig;
$_="<title>$title</title>\n$_";
print STDERR "$ARGV\n";
