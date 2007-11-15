#!/usr/bin/perl

# 20040403 - for demix, allow more than 1 mixture file
# 20040223 - add -k option
# 20040222 - defer IO::Ftp loading until needed (for running under Windows' ActivePerl, which doesn't have Math::XOR yet)
#          - replace Math::XOR with Perl's ^ (d'oh!)
#          - add -1 option
#          - add -v (not implemented yet) and -V
# 20031215 - IO::Ftp support for target (currently for demixing only; doesn't work yet)
# 20031125 - add -X for a multibyte xor key
# 20031027 - add xor option
# 20020718

$|++;
use strict;
use Getopt::Std;

my $PRG = 'mixfiles.pl';

my %opts;
my $action = 'mix';
my $chunk = 1024;
my $dst;
my @src;
my $s = "";
getopts('hdofs:x:X:pvV1k:', \%opts);

sub show_progress {
    return unless $opts{V};
    my ($n, $N) = @_;
    print "\b" x length($s);
    if ($N) {
        $s = sprintf "%.0f of %.0f (%.2f%%) ...", $n, $N, $n/$N*100.0;
    } else {
        $s = sprintf "%.0f ...", $n;
    }
    print STDERR $s;
}

if (exists $opts{h}) {
    print "Usage:\n";
    print "  To mix: $PRG [-Vv] [-s C] [-f] [-x B | -X S] <mixture file> <file1> ...\n";
    print "  To demix: $PRG -d [-Vv] [-f] [-x B | -X S] [-k S] <mixture file ...>\n";
    print "  To xor: $PRG -1 [-Vv] [-x B | -X S] <file>\n";
    print "  -s means set chunksize to C bytes (default is 1024)\n";
    print "  -f means force/overwrite existing files\n";
    print "  -x means xor all content all with byte B (B is a number between 0 and 255)\n";
    print "  -X means xor all content string S (S will be repeated or truncated as\n";
    print "     necessary to be of the same length with C)\n";
    print "  -o means the header is to be read/written to stdout\n";
    print "  -p means use passive ftp\n";
    print "  -V means show progress\n";
    print "  -1 means not mix/demix, but just xor a file and output it to ORIGNAME.xor\n";
    print "  -k means when demixing, skip files that match regex /S/i\n";
    exit 0;
} elsif ($opts{d}) {
    $action = 'demix';
}

my $passive_ftp = exists $opts{p} ? 1:0;
my $force = exists $opts{f} ? 1:0;

@ARGV > 0 or die "$PRG: fatal: no target specified\n";
$dst = shift @ARGV;
if ($opts{s}) {
    $opts{s} = int($opts{s});
    $chunk = $opts{s} if $opts{s} > 0;
}

die "$PRG: fatal: You can't specify both -x and -X!\n" if defined($opts{x}) && defined($opts{X});
die "$PRG: fatal: -1 must be accompanied by -x or -X!\n" if $opts{1} && !(defined($opts{x}) || defined($opts{X}));
die "$PRG: fatal: -1 must not be used with -d!\n" if $opts{1} && $opts{d};
$action = 'xor' if $opts{1};

my $xorfunc;
if (defined $opts{x}) {
    $opts{x} = int($opts{x});
    if ($opts{x} > 0 and $opts{x} < 255) {
        my $xorkey = chr($opts{x}) x $chunk;
        $xorfunc = sub { $_[0] ^ $xorkey };
    } else {
        die "$PRG: fatal: xor value must be between 1 and 254\n";
    }
} elsif (defined $opts{X}) {
    die "$PRG: fatal: you must use a non-empty string for -X!\n" unless length($opts{X});
    my $xorkey;
    if (length($opts{X}) > $chunk) { $xorkey = substr($opts{X}, 0, $chunk) } else { $opts{X} = $opts{X} x ($chunk/length($opts{X}) + 1); $xorkey = substr($opts{X}, 0, $chunk) }
    $xorfunc = sub { $_[0] ^ $xorkey };
} else {
    $xorfunc = sub { $_[0] };
}

if ($action eq 'mix') {
    @ARGV > 0 or die "$PRG: fatal: no files to be mixed specified\n";
    @src = map {[s#.*/##,$_]->[1]} @ARGV;
    my @SRC;
    my @sizes;
    my $srcn = @src-1;

    for (0..$srcn) {
        die "$PRG: fatal: `$src[$_]' doesn't exist or not a normal file\n" unless -f $src[$_];
        $sizes[$_] = -s $src[$_];
        open $SRC[$_], $src[$_] or die "Can't open `$src[$_]': $!\n";
    }

    die "$PRG: fatal: target `$dst' already exists, use -f to overwrite\n" if ((-f $dst) && !$force);
    open DST, ">$dst" or die "$PRG: fatal: can't open `$dst': $!\n";

    my $header = sprintf("%d,%d->%s\n", scalar(@src), $chunk, join("", map{ $src[$_]."\0".$sizes[$_]."\0" } 0..$srcn));
    if (exists $opts{o}) {
        print $header;
    } else {
        syswrite DST, $header;
    }
    
    my $nonzero;
    my $n;
    my $buf;
    my $totalbytes = 0;
    do {
        $nonzero = 0;
        for (0..$srcn) {
            next if $sizes[$_]==0;
            $nonzero++;
            $n = $sizes[$_] >= $chunk ? $chunk : $sizes[$_];
            sysread $SRC[$_], $buf, $n;
            syswrite DST, $xorfunc->($buf);
            $sizes[$_] -= $n;
            $totalbytes += $n;
        }
        show_progress($totalbytes);
    } while $nonzero;
    close DST or die "$PRG: fatal: can't write to `$dst': $!\n";
}

if ($action eq 'demix') {
    my @dst = ($dst, @ARGV);
    my @DST;
    
    my $skip_pat;
    if (defined($opts{k})) { $skip_pat = qr/$opts{k}/i }
    
    my @DST;
    my $mixsize;
    for (0..@dst-1) {
        if ($dst[$_] =~ s#^ftp://#//#) {
            require IO::Ftp; import IO::Ftp;
            $DST[$_] = IO::Ftp->new('<', $dst[$_], TYPE=>'i', Passive=>$passive_ftp);
        } else {
            open $DST[$_], $dst[$_] or die "$PRG: fatal: can't open `$dst[$_]': $!\n";
            $mixsize += (-s $dst[$_]);
        }
    }
    
    my $info;
    if (exists $opts{o}) {
        $info = <STDIN>;
    } else {
        $info = <$DST[0]>;
        sysseek $DST[0], length($info), 0;
    }

    my ($srcn, $chunk, $files) = $info =~ /^(\d+),(\d+)->(.+)/ or die "$PRG: fatal: `$dst[0]': invalid header a\n";
    $srcn--;
    my @src;
    my @sizes;
    my @SRC;
    my @skip;
    while ($files =~ /([^\0]+)\0(\d+)\0/g) {
        push @src, $1;
        push @sizes, $2;
        push @skip, ($skip_pat && $src[-1] =~ $skip_pat ? 1:0);
        if ($skip[-1]) { print STDERR "$PRG: notice: `$src[-1]' will be skipped\n" }
    }
    @src == $srcn+1 or die "$PRG: fatal: `$dst': invalid header b\n";
    
    for (0..$srcn) {
        next if $skip[$_];
        die "$PRG: fatal: `$src[$_]' already exists, use -f to overwrite\n" if (-e $src[$_]) && !$force;
        open $SRC[$_], ">$src[$_]" or die "Can't open `$src[$_]': $!\n";
    }
    
    my $nonzero;
    my $n;
    my $buf;
    my $totalbytes = 0;
    my $dstno = 0;
    do {
        $nonzero = 0;
        for (0..$srcn) {
            next if $sizes[$_]==0;
            $nonzero++;
            $n = $sizes[$_] >= $chunk ? $chunk : $sizes[$_];
            sysread $DST[$dstno], $buf, $n;
            if (length($buf) < $n && $dstno+1 <= @dst) {
                # must move to next file
                my $buf2;
                $dstno++;
                open $DST[$dstno], $dst[$dstno] or die "$PRG: fatal: can't open `$dst[$dstno]': $!\n";
                sysread $DST[$dstno], $buf2, ($n-length($buf));
                $buf .= $buf2;
            } 
            unless ($skip[$_]) { syswrite $SRC[$_], $xorfunc->($buf) }
            $sizes[$_] -= $n;
            $totalbytes += $n;
        }
        show_progress($totalbytes, $mixsize);
    } while $nonzero;
    for (0..$srcn) {
        next if $skip[$_];
        close $SRC[$_] or die "$PRG: fatal: can't write to `$src[$_]': $!\n";
    }
}

if ($action eq 'xor') {
    @ARGV == 0 or warn "$PRG: warning: extra arguments are ignored\n";
    
    my $DST;
    my $mixsize;
    open $DST, $dst or die "$PRG: fatal: can't open `$dst': $!\n";
    $mixsize = -s $dst;
    
    my @src = ("$dst.xor");
    my @sizes = ();
    my @SRC;
    my $srcn = 0;

    for (0..$srcn) {
        die "$PRG: fatal: `$src[$_]' already exists, use -f to overwrite\n" if (-e $src[$_]) && !$force;
        open $SRC[$_], ">$src[$_]" or die "Can't open `$src[$_]': $!\n";
    }
    
    my $nonzero;
    my $n;
    my $buf;
    my $totalbytes = 0;
    do {
        $nonzero = 0;
        for (0..$srcn) {
            next if $sizes[$_]==0;
            $nonzero++;
            $n = $sizes[$_] >= $chunk ? $chunk : $sizes[$_];
            sysread $DST, $buf, $n;
            syswrite $SRC[$_], $xorfunc->($buf);
            $sizes[$_] -= $n;
            $totalbytes += $n;
        }
        show_progress($totalbytes, $mixsize);
    } while $nonzero;
    for (0..$srcn) {
        close $SRC[$_] or die "$PRG: fatal: can't write to `$src[$_]': $!\n";
    }
}
