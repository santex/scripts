#!/usr/bin/perl

# 040505 - extract <title>...</title> for each *.html and *.htm file in the
# directory.

use URI::Escape;

@files = (); # [filename, sortable string, actual title]

for $file (<*.html>, <*.htm>) {

  open F, $file or do { warn "WARN: Can't open $file: $!, skipped\n"; next };
  $_ = join "", <F>;
  close F;
  
  if (m#<TITLE[^>]*>(.+?)</TITLE>#si) {
    $title = $1;
    
    $sortsubj = $1;
    for ($sortsubj) {
      $_ = lc;
      s/^\s+//s; s/\s+$//s;
      s#<[^>]+>##sg;
    }
  } else {
    $title = "(no subject)";
    $sortsubj = lc $file;
  }
  
  push @files, [$file, $sortsubj, $title];
}

print "<ol>\n";
for (sort {$a->[1] cmp $b->[1]} @files) {
  print "<li><a href=\"".uri_escape($_->[0])."\">$_->[2]</a><br>\n";
}
print "</ol>\n";
