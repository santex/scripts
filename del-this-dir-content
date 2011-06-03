#!/usr/bin/perl

# 040610 - duh, kadang2 unix itu suck juga. kalo ada sebuah dir isinya
# banyak banget, sehingga 'rm *' selalu 'argument list too long', there's
# always no easy and efficient way to clean it.

opendir D, ".";
while ($e = readdir D) {
  next if $e eq '.' || $e eq '..';
  print "$e\n";
  unlink $e;
}
close D;
