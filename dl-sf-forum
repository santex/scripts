#!/usr/bin/perl

#021201, diambil dari dl-sf-archive, tinggal ganti url forum aja.
# ubah regex sedikit, tambahin 

if (-f "/etc/.builder") {
    $stripper = "/home/steven/bin/strip-sfforum-thread-page.pl";
    $distributor = "/home/steven/bin/distribute-monthly-sf-threadpage-files.pl";
} else {
    $stripper = "/home/sroot/strip-sfforum-thread-page.pl";
    $distributor = "/home/sroot/distribute-monthly-sf-threadpage-files.pl";
}

use LWP::Simple;
$|++;
$XURLS = "/home/sroot/xurls.pl";
sub system2($) {print "$_[0]\n"; system $_[0];}
@ARGV==2 or die "Usage: $0 forumname forumid\n";
($FORUM_NAME,$FORUM_ID)=@ARGV;
mkdir $FORUM_NAME,0755;chdir $FORUM_NAME;
$_=0;
do {
  $page = get "http://sourceforge.net/forum/forum.php?max_rows=25&style=ultimate&offset=$_&forum_id=$FORUM_ID";
  open F,">$_.html"; print F $page; print "$_.html\n"; close F;
  $_+=25;
} while $page =~ m#<B>Next Messages #; # m#<A HREF="forum\.php\?thread_id=\d+&forum_id=\d+">#;

system2 $XURLS . q! [0-9]*.html | perl -lne'print "http://sourceforge.net/forum/$1" if m#(forum\.php\?thread_id=\d+&forum_id=\d+)#;' >urls.txt!;
system2 "wget -qxi urls.txt";
chdir "sourceforge.net/forum/" or die;
system2 q!find -type f|xargs -n 1000 perl -e'for(@ARGV){/thread_id=(\d+)/ or next;rename $_,"$1.html"}'!;
system2 qq!$stripper *!;
system2 qq!$distributor!;

chdir "../../";
system2 "rm *.html urls.txt";
chdir "../";
system2 "tar cfj $FORUM_NAME.tar.bz2 $FORUM_NAME && rm -rf $FORUM_NAME";
