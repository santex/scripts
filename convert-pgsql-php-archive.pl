#!/usr/bin/perl

# 040107

# arsip milis pgsql di http://archive.postgresql.org/ dibuat dengan *.php.
# tidak berkelakuan baik dengan IE (IE shows it as plain text) dan swish++
# (swish++'s search won't show the files' titles). skrip ini mengubah *.php
# menjadi *.html termasuk link2 di dalamnya, dan menambahkan <title> jika
# belum ada (versi lama archives.postgresql.org menggunakan <h2>, how
# stupid...), sekalian bersihin bloat.

# 040116 - ganti \d+ jadi \w+ agar some other .php links get caught too

for $file (<*.php>) {
  ($new_file = $file) =~ s/\.php[34]?$/.html/i;
  open F, $file; $content = join "", <F>; close F;
  
  for ($content) {
    s#(<a\s+(?:name="\w+"\s+)?href="\w+).php([^"]*)">#$1.html$2">#ig;
    s#(<body[^>]*>).+<!--X-TopPNI-End-->#$1#si;
    s#<!--X-User-Footer-->.+<!--X-User-Footer-End-->##si;
    if (/<!--X-Head-End-->/) {
      s#^.+<!--X-Head-End-->##s;
    } else {
      s#^.+?<H2>(.+?)</H2>#<html><head><title>$1</title></head><body><h2>$1</h2>#s;
    }
  }
  
  open F, ">$new_file"; print F $content; close F;
  unlink $file;
}
