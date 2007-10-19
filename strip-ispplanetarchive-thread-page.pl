#!/usr/bin/perl -0 -pi
#021117 - actually this strips either an index page or message page
($title)=m#(<title>.+?</title>)#i;
if (m#<span class="msgtitle">#) { # message page
    s#.+(<span class="msgtitle">)#$1#s;
    s#<!--X-User-Footer-->.+##s;
} else { # index page
    s#.+(<span class="siteheader">)#$1#s;
    s#(Last Page</a>\n</span>).+#$1#s;
}
$_ = "$title\n$_";
print STDERR "$ARGV\n";
