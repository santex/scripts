#!/usr/bin/perl -0

# first written 011105 for mwmag edisi 2
# rewritten 031130 buat buku resep php

use File::Find;
use URI::Escape;

%fids = (); %aids = ();

for $f (<*.html>) { next unless $f =~ /^(\d+)\.html$/; $fids{$1}++ }
for $d (grep {(-d) && /^\d+$/} <*>) {
  chdir $d;
  for $f (<*.html>) { next unless $f =~ /^(\d+)\.html$/; $aids{$1}++ }
  chdir "..";
}

for $f (<*.html>) { next unless $f =~ /^(\d+)\.html$/;
  open F, $f; $_ = <F>;
  s#(/knowledge_base/index.phtml/fid/)(\d+)(")# exists $fids{$2} ? "$2.html$3" : "$1$2$3" #eg;
  s#(/knowledge_base/view.phtml/aid/)(\d+)(/fid/)(\d+)(")# exists $aids{$2} ? "$4/$2.html$5" : "$1$2$3$4$5" #eg;
  s#"/clickthrough/index.phtml\?sendtourl=([^"]+)"# uri_unescape($1) #eg;
  open F, ">$f"; print F $_;
}

for $d (grep {(-d) && /^\d+$/} <*>) {
  chdir $d;
  for $f (<*.html>) { next unless $f =~ /^(\d+)\.html$/;
    open F, $f; $_ = <F>;
    s#(/knowledge_base/index.phtml/fid/)(\d+)(")# exists $fids{$2} ? "../$2.html$3" : "$1$2$3" #eg;
    s#(/knowledge_base/view.phtml/aid/)(\d+)(/fid/)(\d+)(")# exists $aids{$2} ? "../$4/$2.html$5" : "$1$2$3$4$5" #eg;
    s#"/clickthrough/index.phtml\?sendtourl=([^"]+)"# uri_unescape($1) #eg;
    open F, ">$f"; print F $_;
  }
  chdir "..";
}
  