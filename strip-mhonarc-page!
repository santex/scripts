#!/usr/bin/perl -0 -pi
#030125
($title) = m#<a href=[^>]+>(?:<img[^>]+>)?(.+?)</a>#i or $title = $ARGV; $title =~ s/^\s+//; $title =~ s/\s+$//;
s|.*?<!--X-User-Header-End-->||s;
s|<!--X-User-Footer-->.*||s;
$_="<title>$title</title>\n$_";
print STDERR "$ARGV\n";

__END__
#020819 - doesn't work anymore, 021117
s#<style.+?</style>##sig;
s#<script.+?</script>##sig;
s#.+(<H3>Email Archive:.+</pre>).*#$1#si;
s#<img#<ximg#ig;
