#!/usr/bin/perl

while (<>) {
	do {print; next} if /#/ or not /\S/;
	
	$cap = "";
	(($cap = $_) =~ s/([a-z])/uc($1)/e) if $_ eq lc;

	print;
	print $cap if $cap;
}
