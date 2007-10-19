#!/usr/bin/perl -0 -pi
require "/home/steven/bin/func-contrive-subject.pl";

tr#\015#\012#;
s#</?font[^>]*>##sig;

# title
($title) = /<BR>SUBJECT:\s*([^<]+)/; $title = contrive_subject($title);
$_ = "<head><title>$title</title></head><body bgcolor=#ffffff><h1>$title</h1></title>$_</body>" unless /<title>/;

# colorize
unless (m#<!--[colorized]-->#) {
    s#^((?:\s|&nbsp;)*&gt;(?:\s|&nbsp;)*&gt;(?:\s|&nbsp;)*&gt;(?:\s|&nbsp;)*&gt;.*)#<em class=quotelev4>$1</em>#mg;
    s#^((?:\s|&nbsp;)*&gt;(?:\s|&nbsp;)*&gt;(?:\s|&nbsp;)*&gt;.*)#<em class=quotelev3>$1</em>#mg;
    s#^((?:\s|&nbsp;)*&gt;(?:\s|&nbsp;)*&gt;.*)#<em class=quotelev2>$1</em>#mg;
    s#^((?:\s|&nbsp;)*&gt;.*)#<em class=quotelev1>$1</em>#mg;
    s|</head>|<!--[colorized]--><style>pre{font-family:georgia,times} .quotelev1{color:#990099} .quotelev2{color:#ff7700} .quotelev3{color:#007799} .quotelev4{color:#95c500}</style></head>|i;
}
                          