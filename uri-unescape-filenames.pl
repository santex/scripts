#!/usr/bin/perl
use URI::Escape;
rename $_,uri_unescape($_) for @ARGV;
