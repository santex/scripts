#!/usr/bin/perl

# 030523. 64 bit distributed id. bisa dinyatakan angka 64 bit biasa atau
# dalam 14 digit "special base 29" dalam format AAAAA-AAAA-AAAAA. digit2
# dalam "special base 29" ini dipilih dari angka dan huruf di set [A-Z0-9]
# yang tidak ambigu. misalnya, l (huruf el) tidak dipakai karena ambigu
# dengan 1 (angka 1), o (huruf o kecil), dsb. string DID is great untuk
# disalin dari kertas karena mengurangi salah ketik. digit pertama string
# DID juga mengandung checksum (ada ruang karena 29^14 memakan 66,5 bit,
# berarti kita ada 2 bit untuk checksum), so DID is great for nomor
# rekening, user id, dsb. not that great sih, karena cuman 2 digit
# checksumnya, but it's better than nothing.
#
# note: 64 bit juga bisa dinyatakan dengan max. 20 digit desimal, tapi kalau
# untuk keperluan userid untuk IVR/telepon, sebaiknya bikin id tambahan
# saja. terlalu merepotkan mengetik/menyalin 20 digit (kartu kredit aja
# cuman 16 digit). pake string DID juga repot kalau untuk telepon/HP, sebab
# mencampur antara angka dan huruf.

my @DIGITS = split //, "0123456789abcdefhjkmnpqrtvwxy";
my %DIGITS_POS; $DIGITS_POS{$DIGITS[$_]} = $_ for 0..$#DIGITS;

#030523
sub string2numericdistid {
    my $s = shift;
    my $n = 0;
    
    $s =~ /^[A-Za-z0-9]{5}[ _-]?[A-Za-z0-9]{4}[ _-]?[A-Za-z0-9]{5}$/ or return "[ERR:SYNTAX  ]";
    for ($s) { s/-//g; tr/ABCDEFGHIJKLMNOPQRSTUVWXYZgilosuz/abcdef9h1jk1mn0pqr5tvvwxy291105v2/; }
    
    my $i=0; my $fd; my $magnitude = 1.0;
    my $sum = 0;
    for (reverse split //, $s) {
        ++$i; do { $fd=$_; $n += int($DIGITS_POS{$_}/16)*$magnitude; next } if $i==14;
        $n += $DIGITS_POS{$_}*$magnitude;
        $sum += $DIGITS_POS{$_}*$i*7;
        $magnitude *= 29;
    }
    my $check = $sum % 16;
    ($DIGITS_POS{$fd} & 15) == $check ? $n : -1;
}

#030523
sub numeric2stringdistid {
    my $n = int(shift);
    my $s = "";
    $n >= 0 or return "[ERR:VALUE   ]";
    
    if ($n == 0) {
        $s = "0";
    } else {
        while ($n > 0) { $s = $DIGITS[$n % 29] . $s; $n = int ($n/29); }
    }
    
    $s = sprintf "%014s", $s;
    my $i = 15; my $sum = 0;
    for (split //, $s) { --$i; next if $i==14; $sum += $DIGITS_POS{$_}*$i*7; }
    my $check = $sum % 16;
    $s =~ s/(.)/ $DIGITS[ $DIGITS_POS{$1}*16 + $check ] /e;
    $s =~ s/(.....)(....)(.....)/$1-$2-$3/;
    $s;
}

#030523
sub canonical_stringdistid {
    my $s = shift;
    $s =~ /^[A-Za-z0-9]{5}[ _-]?[A-Za-z0-9]{4}[ _-]?[A-Za-z0-9]{5}$/ or return "[ERR:SYNTAX  ]";
    for ($s) { s/[ _-]//g; tr/ABCDEFGHIJKLMNOPQRSTUVWXYZgilosuz/abcdef9h1jk1mn0pqr5tvvwxy291105v2/; }
    $s =~ s/(.....)(....)(.....)/$1-$2-$3/;
    $s;
}

# simple tests
sub test_distid {
    my $s; my $n; my $k; my $v;

    # convert numbers to string distid and back
    my %r1 = (
        0, '00000-0000-00000',
        1, '70000-0000-00001',
        10, '60000-0000-0000a',
        28, '40000-0000-0000y',
        29, 'e0000-0000-00010',
        30, '50000-0000-00011',
        1000, 'd0000-0000-0015e',
        10000, 'd0000-0000-00bvt',
        100000, 'e0000-0000-042w8',
        1000000, 'b0000-0000-1c01q',
        100000000000, '30000-05r3-bf362',
        2**32+10, 'c0000-0076-bekhw',
        2**32+15, '20000-0076-bekj2',
    );
    my %r2 = (
        -1, ['00000-05r3-bf362','10000-05r3-bf362','40000-05r3-bf362','50000-05r3-bf362',
             '60000-05r3-bf362','70000-05r3-bf362','80000-05r3-bf362','90000-05r3-bf362',
             'a0000-05r3-bf362','b0000-05r3-bf362','c0000-05r3-bf362','d0000-05r3-bf362',
             'e0000-05r3-bf362','f0000-05r3-bf362','h0000-05r3-bf362','j0000-05r3-bf362',
             'k0000-05r3-bf362',                   'n0000-05r3-bf362','p0000-05r3-bf362',
             'q0000-05r3-bf362','r0000-05r3-bf362','t0000-05r3-bf362','v0000-05r3-bf362',
             'w0000-05r3-bf362','x0000-05r3-bf362','y0000-05r3-bf362',
             
             '00003-05r3-bf362','30000-5r30-bf362','30000-0053-bf362','30000-005r-bf362',
             '30000-05r3-fb362','30000-05r3-bf632','30000-05r3-bf326',
            ],
    );
    my %r3 = (
        '00000-0000-00000',['ooooo-oooo-ooooo','OOO0OooooO0OOO'],
        '30000-05r3-bf362',['3OOOO 0Sr3 Bf362'],
        '12345-6789-0abcv',['IZ345-678G-OabcU','iz345 678g OabcU','Lz345 6789 oabcv'],
        'aaaaa-aaaa-aaaaa',['AAAAA_AAAA-AAAAA'],
        '[ERR:SYNTAX  ]',['12345-1234-1234','123456789012345','1234-12345-12345','--------------','[ERR:SYNTAX  ]'],
    );

    print "1. test convert numeric distid to string distid ";
    while (($k,$v) = each %r1) { $s = numeric2stringdistid($k); print $s eq $v ? ".":"[FAIL: $s ne $v]" }
    
    print "\n2. test convert string distid back to numeric distid ";
    while (($k,$v) = each %r1) { $n = string2numericdistid($v); print $n == $k ? ".":"[FAIL: $n != $k]" }

    print "\n3. test checksum ";
    for my $k (keys %r2) { for (@{$r2{$k}}) { $n = string2numericdistid($_); print $n == $k ? ".":"[FAIL: $n != $k]" } }

    print "\n4. test canonical ";
    for my $k (keys %r3) { for (@{$r3{$k}}) { $s = canonical_stringdistid($_); print $s eq $k ? ".":"[FAIL: $s != $k]" } }

    print "\n";
}
test_distid();
__END__

....,....+....,....+....,....+....,....+

0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ
0123456789abcdefghijklmnopqrstuvwxyz

0123456789ABCDEF6H1JK1MN0PQR5TVVWXY2

....,....+....,....+....,....+....,....+

0123456789ABCDEFHJKMNPQRTVWXY
0123456789abcdefhjkmnpqrtvwxy

....,....+....,....+....,....+....,....+

0 = 0, o, O
1 = 1, i, I, l, L
2 = 2, z, Z
5 = 5, s, S
9 = 9, g, G
v = v, V, u, U
