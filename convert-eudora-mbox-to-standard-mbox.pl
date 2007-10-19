#!/usr/bin/perl -0 -ni

#021028 - craps eudora does to its "mbox":
# - break out mime messages/attachments, but leave Content-Type: multipart...
#   i think this extraction has less to do with efficiency than it has to do with trapping users with eudora
#   (users can't just move the mbox files around and use it in another mua)
# - "<x-html>" and "<x-flowed>" crap.

s#\015##g; # unixify dulu

for $msg (split /^From /m, $_) {
    next unless /\S/;
    
    if ($msg =~ m#<x-html>#) {
        $msg =~ s#^Content-Type: .+(?:\n\s+.*)*#Content-Type: text/html; charset="iso-8859-1"#m;
        $msg =~ s#</?x-html>##g;
    } else {
        $msg =~ s#</?x-flowed>##g;
    }
    print "From ",$msg;
}
