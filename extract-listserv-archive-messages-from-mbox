#!/usr/bin/perl

use POSIX qw(strftime);

$|++;
$in_header = 0;
$in_l_header = 0;
$line_encountered = 0;
$l = 0;
@l_headers = ();
$s2 = 0;

while (<>) {
    if (/^From /) {
        $line_encountered = 0;
        $in_header++;
        next;
    }
    
    if ($in_header) {
        if (not /\S/) {
            $in_header = 0;
        }
        next;
    }
    
    # in body
    if (/^={73}/) {
        $line_encountered++;
        $in_l_header++;
        print "\n\n" if $l++;
        next;
    }
    if ($in_l_header) {
        if (not /\S/) {
            print $from_;
            print @l_headers;
            print;
            @l_headers = ();
            $in_l_header = 0;
        } else {
            s/:\s{2,}/: /;
            if (/^Date:/) {
                s/(\w+), (\d{1,2}) (\w+) (\d{2,4}) (\d+:\d+:\d+) /$1 $3 $2 $5 $4 /;
                $from_ = "From - $1 $3 $2 $5 $4\n";
            }
            push @l_headers, $_;
        }
        next;
    }
    
    #in l_body
    next if /^ ={77}/;
    do {print "--\n"; next} if /^ ={76}/;
    print if $line_encountered;
}
