#!/usr/bin/perl

use HTML::LinkExtor;
use LWP::UserAgent;
use URI::URL;
#use Data::Dumper;
$|++;

my $ua = new LWP::UserAgent;
my $p = new HTML::LinkExtor;
my %urls = ();

sub check {
  my $url = shift;
  return unless $url->scheme =~ /^(https?)$/;
  return if $urls{ $url->abs }++;

  my $req = HTTP::Request->new(GET => $url);
  my $res = $ua->request($req);

  printf "%s: %s %s\n", $url->abs, $res->code, $res->message;

  if ($res->code =~ /^2/ && $res->content_type eq 'text/html') {
    for ($p->parse($res->content)->links) {
      my ($tag, $attrn, $attrv) = @$_;
      my $url2 = url(url($attrv, $url)->abs);
      check($url2) if $url2->netloc eq $url->netloc;
    }
  }
}

check(url($_)) for @ARGV;
