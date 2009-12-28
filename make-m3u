#!/usr/bin/perl
# 000306, steven

use File::Find;
use URI::Escape;

die <<"USAGE" unless @ARGV >= 2;
usage: $0 BASEURL DIR ... >PLAYLIST.M3U

all this script does is traverse DIR(s), find all MP3 files, 
and prepend them with BASEURL.

USAGE

($BASEURL, @DIR) = @ARGV;
$BASEURL .= "/" unless $BASEURL =~ m[/$];

for $dir (@DIR) {
	find
		sub {
			return unless /\.mp(2|3)$/i;
			($base = $File::Find::dir) =~ s[^\Q$dir/][]i;
			print "$BASEURL", uri_escape("$base/$_"), "\n";
		},
	$dir;
}

