#!/usr/bin/perl

use strict;

use Number::Fraction ':constants';

# L=length, T=time, M=mass, I=electrical current,
# th(theta)=temperature, N=amount of substance, J=luminous intensity

sub valid_dimsym {
  my $sym = shift;
  $sym =~ m#\A (?: (L|T|M|I|th|N|J) (?:-?\d+(?:/\d+)?)? )+ \z#x ? 1:0;
}

my %dimsym_order = (L=>1, T=>2, M=>3, I=>4, th=>5, N=>6, J=>7);

sub canonicalize_dimsym {
  my $sym = shift;
  valid_dimsym($sym) or return;
  my %el;
  while ($sym =~ m#(L|T|M|I|th|N|J) (-?\d+(?:/\d+)?)?#xg) {
    my ($let, $num) = ($1, $2); $num=1 if $num eq '';
    #print "$let $num\n";
    $el{$let} ||= Number::Fraction->new(0);
    $el{$let} += Number::Fraction->new($num);
  }
  join "", 
    map { $_ . ($el{$_} == 1 ? "" : $el{$_}) } 
      sort {$dimsym_order{$a} <=> $dimsym_order{$b}} keys %el;
}

sub dimsym_is_canonical {
  my $sym = shift;
  valid_dimsym($sym) && $sym eq canonicalize_dimsym($sym);
}

my @dims = ("L", "xxx", "L1T1", "LLTTT", "th-2T1L1", "MNJ", "M-8/12T3N", "L2T-6/3");
for (@dims) {
  print "$_: ";
  if (valid_dimsym($_)) {
    print canonicalize_dimsym($_), "\n";
  } else {
    print "invalid\n";
  }
}
