#!/usr/bin/perl

#021121

use MIME::Parser;
$|++;

@ARGV==1 or die "Usage: $0 <mboxfile>\n";
$mbox = $ARGV[0]; open MBOX, $mbox or die "Can't open mbox: $!\n";
$counter = 0; while (1) { $dir = "$mbox.dir".($counter++?".$counter":""); last if mkdir $dir,0755 }
print "Will output to `$dir/'\n";


{ local $/; $_ = <MBOX>; }

$i = 0;
while (/^(?:From [^\n]+\n)(.+?)(?=^From |\Z)/msg) { push @msgs, $1 }

chdir $dir or die "Can't chdir to $dir: $!\n";
for (@msgs) {
    ++$i; print "Message $i (${\( length )} bytes)\n";

    $p = MIME::Parser->new;
    $p->extract_nested_messages(0);
    $p->parse_data($_);
    $p->output_dir($dir);
}
