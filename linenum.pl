#!/usr/bin/perl -p
#000605. i've perhaps recreated this script ten times or so.
print /\S/ ? sprintf("%4d|", $.) : "    |";
