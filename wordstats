#!/usr/bin/perl

# 2005-10-29 - aneh juga, sampe sekarang belon pernah bikin beginian,
# hehe.

use Getopt::Long;

my %opt = ("case_insensitive" => 1, "top"=>25, "exclude_numbers" => 1);
GetOptions(
  "case-insensitive!" => \$opt{case_insensitive},
  "exclude-numbers!" => \$opt{exclude_numbers},
  "top=i" => \$opt{top},
  "help" => sub { $opt{help} = 1 },
);

if ($opt{help}) {
  print <<USAGE;
wordstats.pl - Count word frequencies from a text.

--[no]case-insensitive   Do case-insensitive (default)
--top=N                  Only show top N words (default=25, 0=show all)
--[no]exclude-numbers    Exclude numbers (default)
--help

USAGE
  exit 0;
}

my %words = ();
my $_ci = $opt{case_insensitive};
my $_xn = $opt{exclude_numbers};
while (<>) {
  for my $word (/(\w+)/g) {
    next if $_xn && $word =~ /^\d+$/;
    if ($_ci) { $words{lc $word}++ } else { $words{$word}++ }
  }
}

#use Data::Dumper; print Dumper \%words; exit;

my $i = 0;
for (sort {$words{$b} <=> $words{$a}} keys %words) {
  $i++;
  last if $opt{top} > 0 && $i > $opt{top};
  printf "%-24s  %4d\n", $_, $words{$_};
}
