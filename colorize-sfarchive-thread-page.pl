#!/usr/bin/perl -0777 -pi
do {
  $_ = "<!--colorized--><style>em {color:#990099;font-family:arial;font-style:normal}</style>\n".$_;
  # gile, kode html sf parah, masa > gak diquote. well...
  s#^(\s*>.+)$#<em>$1</em>#mgi;
  
} unless m#<!--colorized-->#;
