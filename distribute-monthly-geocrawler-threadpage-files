#!/usr/bin/perl -0
#020907
for $f (<*>) {
    $f =~ /^\d+\.html$/ or next;
    open F, $f or do { warn "Can't open $f.html: $!\n"; next };
    $_ = <F>;
    m#<BR>DATE: (\d\d)/\d\d/(\d\d\d\d)# or do { warn "No date: $f.html\n"; next };
    close F;
    $dir = "$2$1";
    if (not -d $dir) {
        if (not mkdir $dir, 0755) { warn "Can't mkdir $dir: $!\n"; next };
    }
    rename $f, "$dir/$f" or do { warn "Can't move $f to $dir/: $!\n"; next };
}

    