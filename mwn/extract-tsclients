#!/usr/bin/perl -0777 -n

# 20040518 - klien techscape bisa diliat di:
# http://techscape.co.id/company/customer.ts?stateid=&pgid=1 skrip ini
# mengekstrak daftar domain dari webpages hasil download.

s!^.+<B>Domain</B>!!s or die "Can't trim #1 (file=$ARGV)";
s!>prev</.+!!s or die "Can't trim #2 (file=$ARGV)";

while (m!<a href=[^>]+>([^<]+)</a>!g) {
  print "$1\n";
}
