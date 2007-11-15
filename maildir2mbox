#!/usr/bin/perl
#000529
#cara kasar untuk convert direktori mail Maildir > mbox
$/=undef;
for(<*>){
	open F, $_ or die;
	print "From -\n", <F>;
	close F;
	print "\n\n";
}
