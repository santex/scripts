#!/usr/bin/perl
use LWP::Simple; 
($s,$t)=@ARGV or die "Usage: $0 FROM TO\neg: $0 USD IDR\n"; 
($_ = get "http://finance.yahoo.com/m5?a=1&s=$s&t=$t") =~ 
  m#<th nowrap>(\d+:\d+[ap]m)</th><td>(\d+\.\d+)</td># or die "Failed\n\n$_";
print "1 $s = $2 $t ($1)\n";
