#!/usr/bin/perl

use strict;
use Mail::POP3Client;
use Getopt::Long;

$|++;

my %opt = (
	ssl=>0
       );
GetOptions(
	   "user=s" => \$opt{user},
	   "pass=s" => \$opt{pass},
	   "host=s" => \$opt{host},
	   "port=i" => \$opt{port},
	   "ssl"    => sub { $opt{ssl} = 1 },
	   "help"   => \$opt{help},
	  );

if ($opt{help}) {
  print <<_;
$0 - Empties a POP mailbox

Usage: $0 --user USER --pass PASS --host HOST
_
  exit 0;
}

die "FATAL: Please specify host\n" unless $opt{host};
die "FATAL: Please specify user\n" unless $opt{user};
die "FATAL: Please specify pass\n" unless $opt{pass};

my $pop = Mail::POP3Client->new(
				HOST   => $opt{host},
				USESSL => $opt{ssl},
				PORT   => $opt{port}||($opt{ssl} ? 995:110),
				AUTH_MODE => 'PASS',
			       );

$pop->User($opt{user});
$pop->Pass($opt{pass});
$pop->Connect or die "FATAL: Can't connect: ".$pop->Message."\n";

my $totsize = 0;
my @list = $pop->ListArray;
for (my $i=1; $i<@list; $i++) {
  print "INFO: Deleting msg $i of ".(-1+@list)." ($list[$i] bytes)\n";
  $pop->Delete($i);
  $totsize += $list[$i];
}
print "INFO: $totsize byte(s) freed\n";# if $totsize;
