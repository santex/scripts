#!/usr/bin/perl

# 20040808

$seen_blank = 0;

while (<>) {
  if ($seen_blank) {
    print;
  } else {
    if (/\S/) {
      s/^(Subject:\s*)\[SPAM\](.*)/$1 . "[THIS IS A SPAM EMAIL - DETECTED BY NETSHELTER]" . $2/e;
    } else {
      $seen_blank++;
    }
    print;
  }
}
