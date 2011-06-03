#!/usr/bin/perl
use Data::Dumper;
use LWP::Simple;
use Mail::Sendmail;
use POSIX qw(strftime);

$_ = get("http://freshmeat.net/backend/fm-releases.rdf");
$content = "";
@m=m#<item .+?<title>(.+?)</title>\s*<link>(.+?)</link>\s*<description>(.+?)</description>#sig;
while(($name,$url,$description)=splice(@m, 0, 3)) {
  $content.=<<_;
$name
$url
$description

_
#print "$name\n$url\n\n";
}

$now = strftime "%Y-%m-%d %H:%M:%S", localtime;
sendmail(
  From=>'headlines-freshmeat@ruby-lang.or.id',
  To=>'steven@ruby-lang.or.id',
  Subject=>"freshmeat.net releases ($now)",
  Message=>$content
) or die $Mail::Sendmail::error."\n";

sub striphtml {
  local $_=shift;
  s/<!--.+?-->//sg;
  s/<.+?>//sg;
  return $_;
}
