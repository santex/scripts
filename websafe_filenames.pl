#!/usr/bin/perl

use Text::Unaccent;

for $orig (@ARGV) {
  for ($safe) {
    $_ = $orig;

    # biasanya nama file prancis/german/dll gitu suka mengandung
    # aksen. konvert dulu ke huruf normalnya (daripada nanti harus
    # diubah jadi "_").
    $_ = unac_string("iso-8859-1", $orig);

    s#/+$##;
    s#[^/A-Za-z0-9_.-]#_#g;
    s#_{2,}#_#g;
  }

  next if $safe eq $orig;

  $counter = 0;
  while (1) {
    $target = $safe . ($counter ? ".$counter" : "");
    unless (-e $target) {
      print "$orig -> $target\n";
      rename $orig, $target;
      last;
    }
    $counter++;
  }
}
