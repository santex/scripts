#!/usr/bin/perl -w

use strict;
use Getopt::Long;

our $VERSION = '0.03 (2007-05-28)';

my %Opt = (
        #vcodec => 'h264',
        #vbitrate => 386,
        #abitrate => 64,

        # 384 kbps, sepertiga mpeg...
        # 2007-05-27 - jelek hasilnya.
        #vcodec => 'xvid',
        #vbitrate => 328,
        #abitrate => 56,

        # i think ffmpeg's --sameq is useless? it picks too low
        # bitrates for mpeg1 (around 220 kbps for video).

        # current best default: h264 2-pass
        # XXX, h264 doesn't support 2pass? 1pass and 2pass result are identical
        vcodec => 'h264',
        vbitrate => 328,
        abitrate => 56,
        pass => 1,

        acodec => 'mp3',
        size => "", # same as input
       );

GetOptions(
           'help' => \$Opt{help},
           'vcodec=s' => \$Opt{vcodec},
           'acodec=s' => \$Opt{acodec},
           'vbitrate=i' => \$Opt{vbitrate},
           'abitrate=i' => \$Opt{abitrate},
           'size=s' => \$Opt{size},

           'version|v' => \$Opt{version},
          );
if ($Opt{version}) {
  print "$0 $VERSION\n";
  exit 0;
} elsif ($Opt{help}) {
  print <<EOF;
$0 $VERSION

Usage:
 $0 [options]

Options:
 --version    Show version and exit.
 --help       Show this message and exit.
 --vcodec     (default: $Opt{vcodec}).
 --acodec     (default: $Opt{acodec}).
 --vbitrate   (default: $Opt{vbitrate}).
 --abitrate   (default: $Opt{abitrate}).
 --size       (default: $Opt{size}).
 --pass       1 or 2 (default: $Opt{pass}).
EOF
  exit 0;
}
#die "Invalid size, use WxH syntax\n" unless $Opt{size} =~ /^\d+x\d+$/;

for my $f (<*.mpg>, <*.mpeg>, <*.dat>, <*.MPG>, <*.MPEG>, <*.DAT>) {
  if (-f "$f.avi") {
    print "WARNING: $f.avi exists, skipped";
  }
  my $esc = esc($f);
  my $opt0 = "-vcodec $Opt{vcodec} -acodec $Opt{acodec} -b $Opt{vbitrate} -ab $Opt{abitrate}".
             ($Opt{size} ? " -s $Opt{size}":"");

  my $cmd;

  if ($Opt{pass} == 1) {
    $cmd = "ffmpeg -i $esc $opt0 $esc.avi";
  } elsif ($Opt{pass} == 2) {
    $cmd = "ffmpeg -i $esc $opt0 -pass 1 $esc.avi && ".
           "rm -f $esc.avi && ".
           "ffmpeg -i $esc $opt0 -pass 2 $esc.avi";
  }

  print "$cmd\n";
  system $cmd;
}

sub esc {
  local $_ = shift;
  s/'/'"'"'/g;
  "'$_'";
}
