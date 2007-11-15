#!/usr/bin/perl

# 040401

use Cwd;
use File::Find;
$|++;

$cwd = getcwd;

finddepth sub {
  #print "dir=$File::Find::dir\n";
  return if $File::Find::dir eq '.';
  return unless -f;
  $i = 0;
  $filename = "$cwd/$_";
  while (-e $filename) { $i++; $filename = "$cwd/$_.$i" }
  rename $_, $filename;
  print "$_ -> $filename\n";
}, ".";
