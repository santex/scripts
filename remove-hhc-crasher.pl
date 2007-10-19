#!/usr/bin/perl -0 -pi

# very long words
s#[A-Za-z0-9]{256,}#[DELETED]#g;

# ASP tags
s/<%/&lt;&#37;/g; s/%>/&#37;&gt;/g;

# XXX hhc also tries to parse *.html.gz, doh.
