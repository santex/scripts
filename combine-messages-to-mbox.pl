#!/usr/bin/perl -0

#021124 - terutama dipake untuk mengconvert message yang dikirim oleh ezmlm
#menjadi mbox. message ini tidak mengandung From_ line, /^From / masih harus
#diconvert menjadi ">From ", dan masih mengandung quoted printable.

use POSIX qw(strftime);

@ARGV>0 or die "Usage: $0 <msgfile> ...\nMbox will be output to stdout\n";
for $file (@ARGV) {
    open F, $file or do { warn "Can't open $file: $!, skipped\n"; next };
    $msg = <F>;
    if ($msg =~ /^Date:\s+(.+)/mi) {
        $date = $1;
        if ($date =~ /(?:(\w+),?\s+)?(\d{1,2})\s+(\w+)\s+(\d{2,4}),?\s+(\d+:\d+(?::\d+)?)/) {
            $dow = $1 || "Thu"; # dummy, males ngitungnya
            $year = $4; $year = ($year < 10 ? "20$year":"19$year") if length($year) == 2;
            $from_ = "From - $dow $3 $2 $5 $year\n";
        } elsif ($date =~ /(?:(\w+),?\s+)?(\w+)\s+(\d{1,2}),?\s+(\d{2,4})\s+(\d+:\d+(?::\d+)?)/) {
            $dow = $1 || "Thu";
            $year = $4; $year = ($year < 10 ? "20$year":"19$year") if length($year) == 2;
            $from_ = "From - $dow $2 $3 $5 $year\n";
        } elsif ($date =~ /(?:(\w+),?\s+)?(\w+)\s+(\d{1,2}),?\s+(\d+:\d+(?::\d+)?)\s+(\d{2,4})/) {
            $dow = $1 || "Thu";
            $year = $5; $year = ($year < 10 ? "20$year":"19$year") if length($year) == 2;
            $from_ = "From - $dow $2 $3 $4 $year\n";
        } else {
            warn "Can't parse Date header in `$file', skipped\n";
            next;
        }
    } else {
        warn "Can't find Date header in `$file', skipped\n";
        next;
    }
        
    print $from_;
    
    $msg =~ s/^From />From /mg;
    $msg =~ s/=([0-9A-Fa-f][0-9A-Fa-f])/chr hex $1/eg;
    print $msg;

    print "\n";
}
