#!/usr/bin/perl

# 2004-12-04

use HTML::Entities;
use POSIX;

$|++;
$/ = undef;
$doc = <>;
%vars = ();

$i = 0;
$vars{table_of_contents} = "";
while ($doc =~ m!<h([123])[^>]*>(.+?)</h\1>!isg) {
  $i++;
  $level = $1;
  $title = remove_tags($2); for ($title) { s/\s+/ /sg; s/^\s+//s; s/\s+$//s; }
  $vars{table_of_contents} .= "&nbsp;" x (4*($level-1)) . "<a href=#addtoc_h$i>$title</a><br>\n";
}
$i = 0;
print STDERR "1a\n";
$doc =~        s!(<h([123])[^>]*>)!"<a name=addtoc_h".(++$i)."></a>$1"!isge or die; # *()!@#()*(!@#^&!@$ kenapa gak mau kalo gue specify full s.d. </hX>???!
print STDERR "1b\n";

$i = 0;
$vars{table_of_pictures} = "";
while ($doc =~ m!\[Gambar ([\d+.]+) (.+?)\]!isg) {
  $i++;
  $num = $1;
  $title = $2; # $title = remove_tags($1); for ($title) { s/\s+/ /sg; s/^\s+//s; s/\s+$//s; }
  $vars{table_of_pictures} .= "<a href=#addtoc_img$i>$num &#150; $title</a><br>\n";
}
$i = 0;
print STDERR "2a\n";
$doc =~        s!(\[Gambar ([\d+.]+) (.+?)\])!"<a name=addtoc_img".(++$i)."></a>$1"!isge or die;
print STDERR "2b\n";

$vars{f_mtime} = POSIX::strftime "%A, %d-%b-%Y", localtime;

$doc =~ s/\[\[(\w+):?(raw)?\]\]/exists($vars{$1}) ? ($2 ? $vars{$1} : encode_entities($vars{$1})) : "[[UNDEFINED:$1:$2]]"/eg;

print $doc;

sub remove_tags {
  local $_ = shift;
  s/<[^>]+>//sg;
  $_;
}
