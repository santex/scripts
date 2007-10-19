#!/usr/bin/perl

# 030526
# - first stab.
# - currently can only download public archive

# 030527
# - getdie() now retries once before giving up

###

$|++;
$SITE = "http://www.topica.com";

use LWP::Simple;

sub getdie($) {
    my $result;

    print "INFO: Retrieving `$_[0]'...";
    $result = get $_[0];
    print " (",length($result)," bytes)\n";
    
    if (!$result) {
        sleep 3;
        print "INFO: Retrying `$_[0]'...\n";
        $result = get $_[0];
        print " (",length($result)," bytes)\n";
    }
    
    die "\nFATAL: Can't get url `$_[0]'\n" unless $result;
    $result;
}

@ARGV==1 or do { print "INFO: Usage: $0 <listname>\n"; exit 0 };
($list=$ARGV[0]) =~ /^\w+$/ or die "FATAL: Bad list name `$list'\n";

print "INFO: Accessing list homepage...\n";
$_ = getdie "$SITE/lists/$list";
/<NOBR><B>&nbsp;Sorry, nothing found/ and die "FATAL: list `$list' not found\n";

# prepare archive dir
if (!(-d $list)) {
    print "INFO: Creating $list/ directory...\n";
    mkdir $list,0755 or die "FATAL: Can't create $list/: $!\n";
}

# get the number of messages
%messageids = ();
if (-f "$list/messageids") {
    print "INFO: Reading $list/messageids...\n";
    open F, "$list/messageids" or die "FATAL: Can't open $list/messageids: $!\n";
    while (<F>) {
        chomp;
        /^\d+$/ or die "FATAL: Syntax error in $list/messageids line $.: $_\n";
        $messageids{$_}++;
    }
    close F;
} else {
    print "INFO: Determining the number of messages for this list...\n";
    $param = "";
    while (1) {
        $_ = getdie "$SITE/lists/$list/read$param";
        /(\d+) Msgs\./ or die "FATAL: Unexpected result\n";
        while (m#/read/message\.html\?mid=(\d+)#g) { $messageids{$1}++ }
        m#(\?sort=d&start=\d+)">Previous Messages</A># or last;
        $param = $1;
    }
    open F, ">$list/messageids" or die "FATAL: Can't open $list/messageids: $!\n";
    for (sort {$a<=>$b} keys %messageids) { print F "$_\n" }
    close F or die "FATAL: Can't write to $list/messageids: $!\n";
}
print "INFO: There are ",scalar(keys(%messageids))," messages for this list\n";

# retrieved unretrieved messages
$retrieved = 0;
for $mid (sort {$a<=>$b} keys %messageids) {
    unless (-f "$list/$mid.html") {
        $_ = getdie "$SITE/lists/$list/read/message.html?mid=$mid";
        m#<TABLE .+?>All Messages</A></FONT></TD>.+?</TABLE>(.+)<TABLE .+?>All Messages</A></FONT></TD>.+?</TABLE>#s
            or die "FATAL: unexpected result, full message page is dumped below:\n\n\n$_";
        $_ = $1;
        s#<IMG SRC="http://statik.topica.com/lists/read/images/icon_pencil.gif.+?>#From: #;
        s#<IMG SRC="http://statik.topica.com/lists/read/images/icon_clock.gif.+?>#Date: #;
        s#<MAP .+?<IMG[^>]+>##s;
        
        open F, ">$list/$mid.html" or die "Can't open $list/$mid.html: $!\n";
        print F $_;
        close F or die "FATAL: Can't write to $list/$mid.html: $!\n";
        $retrieved++;
    }
}

print "INFO: Deleting $list/messageids...\n";
unlink "$list/messageids";

print "INFO: Done retrieving $retrieved messages\n";
