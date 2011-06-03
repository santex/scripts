#!/usr/bin/perl
use LWP::Simple;
use Mail::Sendmail;
use POSIX qw(strftime);

$_ = get("http://slashdot.org/slashdot.rdf");
$content = "";
@m=m#<item>\s*<title>(.+?)</title>\s*<link>(.+?)</link>\s*</item>#sig;
while(($name,$url)=splice(@m, 0, 2)) {
  $content.=<<_;
$name
$url

_
#print "$name\n$url\n\n";
}

$now = strftime "%Y-%m-%d %H:%M:%S", localtime;
sendmail(
  From=>'headlines-slashdot@ruby-lang.or.id',
  To=>'steven@ruby-lang.or.id',
  Subject=>"slashdot.org headlines ($now)",
  Message=>$content
) or die $Mail::Sendmail::error."\n";

sub striphtml {
  local $_=shift;
  s/<!--.+?-->//sg;
  s/<.+?>//sg;
  return $_;
}
