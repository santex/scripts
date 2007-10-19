#!/usr/bin/perl -l

# 2005-12-25

for (<*.wma>) {
  if (-f "$_.mp3") {
    print "WARNING: $_.mp3 exists, skipped";
  }
  $esc = esc($_);
  #$cmd = "ffmpeg -i $esc -ab 128 $esc.mp3 && rm -f $esc";
  $cmd = "ffmpeg -i $esc -ab 128 $esc.mp3";
  print $cmd;
  system $cmd;
}

sub esc {
  local $_ = shift;
  s/'/'"'"'/g;
  "'$_'";
}
