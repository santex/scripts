#!/usr/bin/perl
use LWP::Simple;
($s,$t)=@ARGV or die "Usage: $0 FROM TO\neg: $0 USD IDR\n"; 
($_ = `wget -q -O- 'http://finance.yahoo.com/currency/convert?amt=1&from=$s&to=$t&submit=Convert'`) =~ 
  m#$s$t=X</a></td>\s*<td class="yfnc_tabledata1"><b>1</b></td>\s*<td class="yfnc_tabledata1">(\w+ +\d+)</td>\s*<td class="yfnc_tabledata1">(\d+[.,]\d+)#s or die "Failed\n\n$_";
print "1 $s = $2 $t ($1)\n";
