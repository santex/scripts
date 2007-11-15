#!/usr/bin/perl

# 2005-06-21 - yang udah done juga dicek lagi, karena sering download dobel2/keulang2.
# 040329

$GUID_FILE = "/home/steven/2download-guid.txt";
#$GUID_FILE = "/home/steven/2download-done.txt";

###

use POSIX;

open F, $GUID_FILE or die "FATAL: Can't open '$GUID_FILE': $!\n";
open G, ">$GUID_FILE.new" or die "FATAL: Can't open '$GUID_FILE.new': $!\n";

exit 0 unless @ARGV;
%guids = map {$_ => 1} grep {/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/} @ARGV;

$date = POSIX::strftime "%Y%m%d", localtime;

$i = 0;
while (<F>) {
  $prefix = "";
  $do_rename = 0;
  chomp;
  #goto NEXT if /^#/;
  goto NEXT unless /\S/;
  do { warn "WARN: Bad syntax in line $., skipped\n"; goto NEXT } 
    unless /^(#DONE \d+ \d+# )?([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\s+('.+')\s*(\d+)?$/;
  ($was_done, $guid, $quoted_filename, $filesize) = ($1, $2, $3, $4);
  #print "DEBUG: guid=$guid\n";
  if (exists $guids{$guid}) {
    #print "DEBUG: $guid\n";
    $i++;
    $prefix = $was_done ? "" : "#DONE $date $i# ";
    system "mv $guid $quoted_filename";
    $do_rename++;
    warn "WARN: Can't rename $guid -> $quoted_filename: $?, skipped\n" if $?;
  }
  
  NEXT:
  print G "$prefix$_\n";
  print STDERR "$_\n" if $do_rename;
}

close G;
rename "$GUID_FILE.new", $GUID_FILE or die "Can't update '$GUID_FILE': $!\n";
 
