#!/usr/bin/perl

#20030228 - skr cukup supply forum name, forum id akan dicari sendiri
#20021201

use LWP::Simple;
$|++;
$XURLS = "/home/sroot/xurls.pl"; (-x $XURLS) or $XURLS = "/home/an/xurls.pl"; (-x $XURLS) or $XURLS = "xurls.pl";
sub system2($) {print "$_[0]\n"; system $_[0];}
@ARGV==1 or die "Usage: $0 forumname\n";
$FORUM_NAME=$ARGV[0];
($FORUM_ID) = get("http://sourceforge.net/mailarchive/forum.php?forum=$FORUM_NAME") =~ /forum_id=(\d+)/ or die "FATAL: Can't find out the id number for this forum\n";
mkdir $FORUM_NAME,0755;chdir $FORUM_NAME;
$_=0;
do {
  $page = get "http://sourceforge.net/mailarchive/forum.php?max_rows=25&style=ultimate&offset=$_&forum_id=$FORUM_ID";
  open F,">$_.html"; print F $page; print "$_.html\n"; close F;
  $_+=25;
} while $page =~ m#<a\s+href="forum\.php\?thread_id=\d+&forum_id=\d+">#is;

system2 $XURLS . q! [0-9]*.html | perl -lne'print "http://sourceforge.net/mailarchive/$1" if m#(forum\.php\?thread_id=\d+&forum_id=\d+)#;' >urls.txt!;
system2 "wget -qxi urls.txt";
chdir "sourceforge.net/mailarchive/" or die;
system2 q!find -type f|xargs -n 1000 perl -e'for(@ARGV){/thread_id=(\d+)/ or next;rename $_,"$1.html"}'!;
chdir "../../";
system2 "rm *.html urls.txt";
chdir "../";
system2 "tar cfj $FORUM_NAME.tar.bz2 $FORUM_NAME && rm -rf $FORUM_NAME";
