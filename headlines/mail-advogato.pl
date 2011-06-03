#!/usr/bin/perl
use LWP::Simple;
use Mail::Sendmail;
use HTML::Entities 'decode_entities';
use POSIX qw(strftime);

$_ = get("http://www.advogato.org/rss/articles.xml");
#open F,"articles.xml";$_=join"",<F>;close F;
$content = "";
@m=m#<item>\s*<title>(.+?)</title>\s*<link>(.+?)</link>\s*<description>(.+?)</description>#sig or die "not match!\n";
while(($name,$url,$desc)=splice(@m, 0, 3)) {
  $desc = decode_entities($desc); $desc =~ s/\n/ /g; $desc =~ s/\s{2,}/ /g;
  
  $content.=<<_;
$name
$url
$desc

_
}

$now = strftime "%Y-%m-%d %H:%M:%S", localtime;
sendmail(
  From=>'headlines-advogato@ruby-lang.or.id',
  To=>'steven@ruby-lang.or.id',
  Subject=>"advogato.org headlines ($now)",
  Message=>$content
) or die $Mail::Sendmail::error."\n";

sub striphtml {
  local $_=shift;
  s/<!--.+?-->//sg;
  s/<.+?>//sg;
  return $_;
}
