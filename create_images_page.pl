#!/usr/bin/perl

print "<center>\n";
for(sort grep { /\.(gif|jpe?g?|png)$/i } <*>) {
	print "<img src=$_><br>$_<p>\n";
}
print "</center>\n";
