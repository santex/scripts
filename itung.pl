#!/usr/bin/perl
die <<USAGE unless @ARGV;
Usage: $0 string ...

USAGE

@re = map qr/$_/, @ARGV;


while (<STDIN>) {
	for $i (0..$#ARGV) {
		$n[$i]++ if /$re[$i]/ig;
	}
}

for (0..$#ARGV) {
	print "'$ARGV[$_]': $n[$_] occurence(s)\n";
}

# 991116
