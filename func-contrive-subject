sub contrive_subject {
    local $_=shift;
    my $orig = $_;
    
    # some preprocessing to normalize spaces
    s/[\012\015\t]+/ /g;
    s/ {2,}/ /g;
    s/^\s+//;
    s/\s+$//;

    # hypermail-specific stuff
    return $_ if /: By (Author|Subject|Date|Thread)$/; # jangan ganggu yang ini
    s/^(\d+|\d+-\w+)(\.(mbo?x|txt))?: //i; # nama file di depan
    
    $t=1; $r=0; $f=0;
    while ($t) {
        $t=0;
        s/ \(was:? .+(\)|$)// and do{$t++;next}; # old subject
        s/\bRe:\s*//g and do{$r++;$t++;next}; # reply
        s/\[Fwd: ?(.+)\]/$1/ and do{$f++;$t++;next}; # forward bracket
        s/\bFwd: ?//g and do{$f++;$t++;next}; # reply
        s/\[ ?([^\]]+)( ?\]|$)/length($1) > 16 ? $1 : ""/eg and do{$t++;next}; # list name or text in []? kira2 dari panjangnya aja
    }
    $_ = $f ? "Fwd: $_" : ($r ? "Re: $_" : $_);
    
    #print "$orig  -->  $_\n";

    return $_;
}
1;
