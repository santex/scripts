#!/usr/bin/perl

$prog_path='/usr/local/bin/micq';
$rc_path="$ENV{HOME}/.micqrc";
$data_path="$ENV{HOME}/.micq_uins";
$delay=5*60;

use Expect;
use Data::Dumper;

while(1) {
	unlink $rc_path;
	undef $s;
	$s = Expect->spawn($prog_path) or die;
	#$s->debug(1);

	$s->expect(5, "UIN: #");
	print $s "0\r"; sleep 1;
	$s->expect(2, "password : ") or do { sleep $delay; next;};
	$randpass=join '', map { substr('abcdefghijklmnopqrstuvwxyz',rand(26),1) } 1..5;
	print $s "$randpass\r"; sleep 1;
	$s->expect(2, "verify: ") or next;
	print $s "$randpass\r"; sleep 1;
	$s->expect(30,"!") or next;
	($num) = $s->exp_before() =~ /(\d{8})/;
	#$s->expect(10, "want to use this) : ") or next;
	print $s "0\r"; sleep 1;

	open F, ">>$data_path";
	print F scalar(localtime), ": $num = $randpass\n";
	close F;
	$s->hard_close();
	sleep $delay;
	#exit;
}
