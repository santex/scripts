#!/usr/bin/perl

# 2005-10-29 - aneh juga, sampe sekarang belon pernah bikin beginian,
# hehe.

use Getopt::Long;

my %opt = ("case_insensitive" => 1, "top"=>0, "exclude_numbers" => 1);
GetOptions(
  "case-insensitive!" => \$opt{case_insensitive},
  "exclude-numbers!" => \$opt{exclude_numbers},
  "top=i" => \$opt{top},
  "help" => sub { $opt{help} = 1 },
);

if ($opt{help}) {
  print <<USAGE;
wordstats.pl - Extract words from text

--[no]case-insensitive   Do case-insensitive (default)
--top=N                  Only extract first N words (default=0=show all)
--[no]exclude-numbers    Exclude numbers (default)
--help

USAGE
  exit 0;
}

my %words = ();
my $_ci = $opt{case_insensitive};
my $_xn = $opt{exclude_numbers};
my $_tp = $opt{top};
my $i = 0;
LOOP: while (<>) {
  for my $word (/(\w+)/g) {
    next if $_xn && $word =~ /^\d+$/;
    if ($_ci) { $word = lc $word }
    if ($_tp > 0 && (!exists $words{$word}) && keys(%words) >= $_tp) { last LOOP }
    $words{$word} = ++$i;
  }
}

#use Data::Dumper; print Dumper \%words; exit;

for (sort {$words{$a} <=> $words{$b}} keys %words) {
  print "$_\n";
}
