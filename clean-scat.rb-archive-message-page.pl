#!/usr/bin/perl -0 -pi
m#<TITLE>(.+?)</TITLE>#i; $title=$1||"($ARGV)";
s#.+?(Subject:.+)<hr>.*#$1#si;
s#<a href="/.*?scat\.rb/.*?(\d+)">#<a href=$1>#ig;
print "<title>$title</title>\n<pre>";
