#!/usr/bin/perl
use LWP::Simple;
use Mail::Sendmail;
use POSIX qw(strftime);

$debug = 0;

$_ = get("http://www.detikinet.com");
$content = "";

#$re = qr#<FONT[^>]*>(\w+, \d+/\d+/\d+ .+? WIB)</FONT><BR>\s+<A href="([^"]+)"[^>]*><FONT[^>]*>(.+?)</FONT></A><BR>\s*<font color="ffffff">(.+?)</font>(?:<br>|<hr>)#;
#tanggal 2 jan 2002, detik mengubah htmlnya. sekarang jadi lebih enak... -- tapi gue baru sadar tgl 31 jan :p
$re = qr#<span class="tanggal(?:High)?">([^>]+)</span><BR>\s*<A href="([^">]+)"[^>]+><span class="(?:judulHigh|strJudul)?">(.+?)</span></A><BR>\s*<span class="summary(?:High)?">(.+?)</span>#;

@m = m#$re#sig;

die "No match!\n\n\re = $re\n\ncontent = $_\n\n" unless @m;

while(($date,$url,$title,$summary)=splice(@m, 0, 4)) {
  $title=striphtml($title);
  $summary=striphtml($summary); $summary=~s/\s+$//;
  $url="http://www.detikinet.com$url" unless $url =~ m#http://#;
  $content.=<<_;
$date
$title
$url
$summary

_
}

if ($debug) {
	use Data::Dumper;
	print $content;
	exit 0;
}

$now = strftime "%Y-%m-%d %H:%M:%S", localtime;
sendmail(
  From=>'headlines-detikinet@ruby-lang.or.id',
  To=>'steven@ruby-lang.or.id',
  Subject=>"Detikinet Headlines ($now)",
  Message=>$content
) or die $Mail::Sendmail::error."\n";

sub striphtml {
  local $_=shift;
  s/<!--.+?-->//sg;
  s/<.+?>//sg;
  return $_;
}
