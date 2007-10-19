#!/usr/bin/perl

use YAML::Syck;

$YAML::Syck::ImplicitTyping = 1;

undef $/;

print Dump(Load(scalar <>));

