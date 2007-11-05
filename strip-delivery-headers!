#!/usr/bin/perl -0 -pi
s/(^From .+?\015?\012\015?\012)/rep($1)/semg;
sub rep {
  local $_=shift;
  s/^(X-Received|Received|X-Mozilla-Status2?|X-Mozilla|Delivered-To|X-UIDL|Path): .+(?:\015?\012\s+.*)*\015?\012//mgi;
  return $_;
}
