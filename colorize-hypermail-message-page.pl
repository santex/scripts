#!/usr/bin/perl -0777 -pi
s@(</head>)@<!--colorized--><style>em {color:#990099;font-family:arial;font-style:normal}</style>$1@
unless m#<!--colorized-->#;
