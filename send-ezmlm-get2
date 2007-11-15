#!/usr/bin/perl

$sender = 'davegaramond@icqmail.com';
$list = '';
$delay = 0;

# mengharapkan input:
# list@host.com
#    100
#    101
#    102
# list2@host.com
#    2323
#    2399
#    ...
###

$|++;
use Mail::Sendmail;

$ENV{SENDER} = $sender;

while (<>) {
    chomp;
    s/^\s+//; s/\s+$//;
    if (/\@/) {
        $list = $_;
        next;
    } elsif (/^\d+$/) {
        $recipient = $list; $recipient =~ s/\@/-get.$_\@/;
        print "sending email to $recipient...";
        sendmail(smtp=>'localhost',from=>$sender,subject=>'get archive',to=>$recipient,'return-path'=>"<$sender>") or do {
            print "Can't send mail to $recipient: $Mail::Sendmail::error\n";
            exit 1;
        }
        print "\n";
        sleep $delay;
    }
}
