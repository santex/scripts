#!/usr/bin/perl -0777 -pi
do {
  s@(</head>)@<!--colorized--><style>em {color:#990099;font-family:arial;font-style:normal}</style>$1@i;
  s#^(&gt;.+<BR>)$#<em>$1</em>#mgi;
} unless m#<!--colorized-->#;
