#!/usr/bin/perl
sub sec2hmsd{my $sec=shift;my $d=($sec-int($sec))*10;$sec=int($sec);my $s=$sec%60;my $m=int($sec/60)%60;my $h=int($sec/3600);sprintf"%d:%02d:%02d.%1d",$h,$m,$s,$d;}
for(<>){
  /^(\d+):(\d+):(\d+)\.(\d+):(.*)/;$sec=3600*$1+60*$2+$3+0.1*$4;$t=$5;for($t){s/\|/ /g;s/  / /g;}push @f,[$sec,$t];
}
push @f,[$sec+4,""];
print <<_;
[V4 Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, TertiaryColour, BackColour, Bold, Italic, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, AlphaLevel, Encoding
Style: MainB,Arial,14,65535,65280,65535,0,-1,0,2,2,0,2,16,16,16,0,0

[Events]
Format: Marked, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
_
for(0..@f-2){
  ($sec,$t)=@{$f[$_]};$e1=$sec+4;$e2=$f[$_+1][0];$e=$e1>$e2?$e2:$e1;
  $start=sec2hmsd($sec);$end=sec2hmsd($e);
  print "Dialogue: Marked=0,$start,$end,MainB,,0000,0000,0000,!Effect,$t\015\012"
}
