#!/usr/bin/perl -l

use strict;
use Getopt::Long;

my %Opt = (
        samprate => 44100,
        bitrate => 192,
       );

GetOptions(
           'help' => \$Opt{help},
           'bitrate=i' => \$Opt{bitrate},
           'samprate=i' => \$Opt{samprate},
          );
if ($Opt{help}) {
  print <<EOF;
$0 [options]

Options:
 --help       Show this message and exit.
 --bitrate=B  Set bitrate in kbit, default is 192.
 --samprate=B Set sampling rate in Hz, default is 44100.
EOF
  exit 0;
}

FILE: for my $f (<*.ape>) {
  my $fc = $f; $fc =~ s/\.ape$/.cue/i;
  if (!(-f $fc)) {
    print "WARNING: $fc doesn't exist, skipped";
    next FILE;
  }
  my $esc = esc($f);
  my $escc = esc($fc);
  my $cmd;

  # decompress .ape -> .wav
  if (-f "$f.wav") {
    print "WARNING: $f.wav exists, skipping decompression";
  } else {
    $cmd = "mac $esc $esc.wav -d";
    print $cmd;
    system $cmd;
  }

  unless (-f "$f.wav") {
    print "WARNING: $f.wav doesnt' exist, skipped";
    next FILE;
  }
  
  # encode .wav -> .mp3
  if (-f "$f.mp3") {
    print "WARNING: $f.mp3 exists, skipping encoding";
  } else {
    $cmd = "ffmpeg -i $esc.wav -ar $Opt{samprate} -ab $Opt{bitrate} $esc.mp3";
    print $cmd;
    system $cmd;
  }
  
  unless (-f "$f.mp3") {
    print "WARNING: $f.mp3 doesnt' exist, skipped";
    next FILE;
  }

  # split .mp3 using track timing in .cue
  $cmd = "mp3splt $esc.mp3 -c $escc";
  print $cmd;
  system $cmd;
}

sub esc {
  local $_ = shift;
  s/'/'"'"'/g;
  "'$_'";
}
