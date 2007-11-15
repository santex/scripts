#!/usr/bin/perl

# 040313
# feed this script a copy-paste from tvtome Episode List page

#040414
# add UNAIRED support

if (@ARGV != 1) {
  die "Usage: $0 <title-of-show>\n";
} else {
  $show = shift @ARGV;
}

@epi = ();

while (<>) {
  chomp;
  next unless /^\s*\d+\./;
  ($season, $no, $title) = /^\s*\d+\.\s+(\d+)-\s?(\d+).+?(?:\d\d\d\d?|UNAIRED)\s+\d+\s+\w+\s+\d+\s\s+(.+)/;
  $title =~ s/\s+$//;
  $title =~ s/\s\s+/ /;
  push @epi, [$season, sprintf("%s - %02d%02d - %s", $show, $season, $no, $title)];
}

$last_season = -1;
for (@epi) {
  $season = $_->[0];
  print "\n" if $season ne $last_season && $last_season != -1;
  print $_->[1],"\n";
  $last_season = $season;
}
