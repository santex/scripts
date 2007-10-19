sub get {
  my ($url) = @_;
  my $cmd = "$curl $url 2>".($^O=~/Win32/i ? "nul":"/dev/null");
  print "$0: debug: $cmd\n" if $debug;
  `$cmd`;
}

sub curl {
    my ($uri, $ref, $ses, $dat) = @_;
    my @args = (
        ($curl_major_version>=7 && $curl_minor_version >= 10 ? "-k" : ""), # added 030312, curl 7.10+ pakai peer ssl cert verification soalnya
        "-D -",
        "-H \"User-Agent: Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)\""
    );
    push @args, "-H \"Referer: $HOST$ref\"" if $ref;
    push @args, "-H \"Cookie: $ses\"" if $ses;
    push @args, "--data-binary \"$dat\"" if $dat;
    my $cmd = "$curl ".join(" ", @args)." $HOST$uri 2>".($^O=~/Win32/i ? "nul":"/dev/null");
    print "$0: debug: $cmd\n" if $debug;
    `$cmd`;
}

sub readfile {
    my ($filename) = @_;
    local *F;
    open F, $filename or return;
    local $/;
    <F>;
}

sub writefile {
    my ($filename, $content) = @_;
    local *F;
    open F, ">$filename" or return;
    print F $content;
    close F or return;
    1;
}

sub removescript {
    local $_=shift;
    s#<script\b.+?</script>##sig;
    s#onload\s*=\s*"[^"]+"##sig;
    return "<script>function f(){return true;}window.onerror=f;</script>\n".$_;
}

1;
