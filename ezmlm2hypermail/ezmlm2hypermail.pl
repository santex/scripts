#!/usr/bin/perl -w

# buat/update arsip web dari archive ezmlm -- sh, 011223
# archive is a 2-level directory structures. each posting is in a separate file: 0/00, 0/01, ..., 0/100, 1/00, 1/01, ...
# we append the postings to MMMMYY.mbox files and later run hypermail on these files.

if ($ENV{HOME} =~ /mwi/) {
	$listdir='/home/mwi/milis';
	$archivename='Arsip milis@master.web.id';
	$outputdir='/home/mwi/www/archive/milis@master.web.id';
	$hypermailpath="/usr/bin/hypermail";
} else {
	$listdir='/home/steven/bin/ezmlm2hypermail/home/mwi/milis';
	$archivename='Arsip milis@master.web.id';
	$outputdir='/home/steven/bin/ezmlm2hypermail/milis@master.web.id';
	$hypermailpath="/usr/bin/hypermail";
}

###

%months=(Jan=>"01",Feb=>"02",Mar=>"03",Apr=>"04",May=>"05",Jun=>"06",Jul=>"07",Aug=>"08",Sep=>"09",Oct=>"10",Nov=>"11",Dec=>"12");

if(open F,"$outputdir/counter.txt") { $last=<F>; } else { $last="0,0"; }
($major,$minor)=$last=~/(\d+),(\d+)/;

chdir "$listdir/archive";
@majors = grep {/^(\d+)$/ and $1 >= $major} <*>;
for $ma (@majors) {
  chdir $ma;
  if ($ma == $major) { @minors = grep {/^(\d+)$/ and $1 > $minor} <*>; } else { @minors = grep {/^(\d+)$/} <*>; }
  
  for $mi (@minors) {
    open F,$mi;$msg=join "",<F>;
    ($dd,$bb,$yyyy,$HH,$MM,$SS)=$msg=~m#Received: .+?(\d+) (\w+) (\d+) (\d+):(\d+):(\d+)#s or die "Invalid Received date (message $ma/$mi)\n";
    $last="$ma,$mi";
    $mm=$months{$bb} or die "Invalid month (message $ma/$mi)\n";
    $mbox="$yyyy$mm.mbox";
    if (!$F{$mbox}) { open $F{$mbox}, ">>$outputdir/$mbox" or die "Can't open mailbox `$outputdir/$mbox'\n"; }
    syswrite $F{$mbox}, "From ???\@??? Sat $bb $dd $HH:$MM:$SS $yyyy\n" . $msg . "\n\n";
  }
  chdir "..";
}

for $mbox (keys %F) {
	($yyyymm)=$mbox=~/(\d+)/;
	mkdir "$outputdir/$yyyymm", 0755 unless -d "$outputdir/$yyyymm";
	
	system "$hypermailpath -l '$archivename/$yyyymm.mbox' -m $outputdir/$mbox -d $outputdir/$yyyymm";
}

open F,">$outputdir/counter.txt"; print F "$last\n";

__END__
