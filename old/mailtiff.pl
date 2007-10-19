#!/usr/bin/perl

#001020
#mo ngirim TIFF image ke TPC buat difax

$debug = 0;
$from = 'steven@satunet.com';
$smtp = 'mail.satunet.com';

if (@ARGV != 3) {
	die <<USAGE;
Usage: $0 <Name> <fax number> <TIF file>
Example: $0 'satunet.com/Steven Haryanto' '44(870)134-9386' file.tif
USAGE
}

($name, $fax, $path) = @ARGV;
$clean_name = $name; for ($clean_name) { s/ /_/g; }
($clean_fax = $fax) =~ s/\D//g;

$email = "remote-printer.$clean_name" . 
         '@' . 
         "$clean_fax.iddd.tpc.int";

use MIME::Lite;
### Create a new single-part message, to send a GIF file:
%msg = (From     => $from,
        To       => $email,
        Subject  => "Fax for $name at $fax",
        Type     => 'image/tiff',
        Encoding => 'base64',
        Path     => $path);

if ($debug) {
	use Data::Dumper;
	print Dumper(\%msg);
} else {
	$msg = MIME::Lite->new(%msg);
	$msg->send(smtp => $smtp) or die "Can't send!\n";
}
