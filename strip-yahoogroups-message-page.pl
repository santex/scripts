#!/usr/bin/perl -0777 -pi
#s#.+?<x-html>\s*<table[^>]*>\s*<tr[^>]*>\s*<td[^>]*>\s*(.+)</x-html>.*#$1#si;
s#<table.*?<table.*?<img .*?</table.*?</table>##is;
s#<a href="/group/[^/]+/message/(\d+)">#<a href=$1>#ig;
