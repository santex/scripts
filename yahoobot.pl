#!/usr/bin/perl

$|++;

use Expect;

# gnuyahoo needs to have its yahoo! id+pass and vanilla mode already set in gnuyahoo.scm
$gnuyahoo = "/usr/bin/gnuyahoo";

$exp = new Expect;
$exp->debug(3);
$exp->raw_pty(1);
#$exp->log_stdout(0);
$exp->spawn($gnuyahoo) or die "Can't spawn gnuyahoo: $!\n";

while (1) {
    $exp->expect(5, [
        qr/(.+)/, sub {
            my $self = shift;
            $match = $self->match();
            $match =~ s/([\x00-\x1f\x80-\xff])/sprintf "\\x%02x", ord $1/eg;
            print "got `$match'!\n";
            
            $self->send("pt_mwn how are you\n") if $match =~ /key1/;
            exp_continue;
        },
    ]);
}
