#!/usr/bin/perl
use LWP::Simple;
use Mail::Sendmail;
use POSIX qw(strftime);

$debug = 1;

$_ = get("http://www.detik.com/index.htm");
#$_=join"",<STDIN>;
$content = "";

#$re=qr#<FONT[^>]*>(\w+, \d+/\d+/\d+ .+?)</FONT><BR>\s*<A href="([^"]+)"><FONT[^>]*>(.+?)</A><BR>\s*(.+?)<br><HR>#;
#tanggal 2 jan 2002, detik mengubah htmlnya. sekarang jadi lebih enak... -- tapi gue baru sadar tgl 31 jan :p
$re = qr#<span class="tanggal(?:High)?">(.+?)</span><BR>\s*.*?<A href="([^">]+)"[^>]*>.*?<span class="(?:judulHigh|strJudul)">(.+?)</span></A><BR>.*?<span class="summary(?:High)?">(.+?)</span>#s;

# aneh, lihat <BR>\s*.*?   kalau pake <BR>.*?  kok gak match ya?

@m = m#$re#sig;

die "No match!\n\n\re = $re\n" unless @m;

while(($date,$url,$title,$summary)=splice(@m, 0, 4)) {
  $title=striphtml($title);
  $summary=striphtml($summary); $summary=~s/\s+$//;
  $url="http://www.detik.com$url" unless $url =~ m#http://#;
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
  From=>'headlines-detik@ruby-lang.or.id',
  To=>'steven@ruby-lang.or.id',
  Subject=>"Detik Headlines ($now)",
  Message=>$content
) or die $Mail::Sendmail::error."\n";

sub striphtml {
  local $_=shift;
  s/<!--.+?-->//sg;
  s/<.+?>//sg;
  return $_;
}
