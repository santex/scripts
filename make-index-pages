#!/usr/bin/perl

# 040201

use URI::Escape;
use HTML::Entities;
use File::Find;
use Getopt::Std;

getopts('fhvd', \%opt);

sub usage {
  my $prog = $0; $prog =~ s#.+/##;
  print <<USAGE;
Summary: Recursively make index.html pages for a directory tree.
Usage: $prog -h, -h=help
       $prog [-f] [-v] [-d] <dir>, -f=overwrite/force, -v=verbose, -d=dry run
USAGE
}

sub verbose { return unless $opt{v}; print $_[0], "\n" }

if ($opt{h}) {
  usage();
  exit 0;
}

unless (@ARGV==1) {
  usage();
  exit 1;
}

$opt{v}++ if $opt{d};

find sub { 

  return if $_ eq '..';
  return unless -d;

  $indexdir = $File::Find::dir . ($_ eq '.' ? "/" : "/$_/");
  $indexfile = $indexdir . "index.html";
  
  if (-f("$_/index.html") && !$opt{f}) {
    verbose("$indexfile already exists, skipping");
    return;
  }
  
  $the_dir = $_;
  
  @files = ();
  opendir D, $the_dir;
  @files = grep { $_ ne '..' && $_ ne '.' } readdir(D);
  closedir D;
  
  verbose("Writing $indexfile (${\(scalar @files)} entries)...");
  return if $opt{d};
  
  open F, ">$_/index.html";
  print F "<h1>Index of " . encode_entities($indexdir) . "</h1>\n\n";
  print F map { "<a href=\"" . uri_escape($_) .
                ((-d "$the_dir/$_") ? "/index.html" : "") . "\">" .
                encode_entities($_) .
                ((-d "$the_dir/$_") ? "/</a>" : "</a> (".((-s "$the_dir/$_") || "0")." bytes)") .
                "<br>\n"
              }
          sort {
                 ((-d $b) <=> (-d $a)) ||
                 (lc($a) <=> lc($b))
               } @files;
  close F;

}, $ARGV[0];
