#!/usr/bin/perl -0 -pi
#021117
s#.+<sub>Dec</sub>.+?<TABLE#<TABLE#s;
s#(.+</pre>.+?</TABLE>).+#$1#s;
($title) = m#<a href=[^>]+>(?:<img[^>]+>)?(.+?)</a>#i; $title =~ s/^\s+//; $title =~ s/\s+$//;
s#<img#<ximg#ig;
$_="<title>$title</title>\n$_";
print STDERR "$ARGV\n";

__END__
#020819 - doesn't work anymore, 021117
s#<style.+?</style>##sig;
s#<script.+?</script>##sig;
s#.+(<H3>Email Archive:.+</pre>).*#$1#si;
s#<img#<ximg#ig;
