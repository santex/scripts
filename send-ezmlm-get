#!/usr/bin/perl

$sender = 'davegaramond@icqmail.com';
$list = 'php-general@lists.php.net';
$start = 110901;
$end = 126228;
$delay = 0;

###

$|++;
use Mail::Sendmail;

$ENV{SENDER} = $sender;

$i = $start;
while ($i <= $end) {
    $j = $i+99; $j = $end if $j>$end;
    $recipient = $list; $recipient =~ s/\@/-get.${i}_${j}\@/;
    print "sending email to $recipient...";
    sendmail(smtp=>'localhost',from=>$sender,subject=>'get archive',to=>$recipient,'return-path'=>"<$sender>") or do {
        print "Can't send mail to $recipient: $Mail::Sendmail::error\n";
        exit 1;
    };
    print "\n";
    sleep $delay;
    $i=$j+1;
}
