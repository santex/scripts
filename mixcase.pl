#!/usr/bin/perl -p
s/([A-Za-z])/rand()<0.5?lc($1):uc($1)/eg;
