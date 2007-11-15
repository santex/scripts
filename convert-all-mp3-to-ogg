#!/usr/bin/perl -l

use strict;
use Getopt::Long;

my %Opt = (
        samprate => 44100,
        bitrate => 128,
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
 --bitrate=B  Set bitrate in kbit, default is 96.
 --samprate=B Set sampling rate in Hz, default is 44100.
EOF
  exit 0;
}

for my $f (<*.mp3>) {
  if (-f "$f.ogg") {
    print "WARNING: $f.ogg exists, skipped";
  }
  my $esc = esc($f);
  my $cmd = "ffmpeg -i $esc -ar $Opt{samprate} -ab $Opt{bitrate} $esc.ogg";
  print $cmd;
  system $cmd;
}

sub esc {
  local $_ = shift;
  s/'/'"'"'/g;
  "'$_'";
}
