#!/usr/bin/perl -0 -ni
use Mail::Sendmail '$address_rx';
while (m#(<!--.+?-->|<script.+?</script>|<style.+?</style>)|(<[^>]+>)|([^<]+)#sig) {
    if ($1) { # comment/blocks
        print $1;
    } elsif ($2) { # tag
        $tag = $2;
        if ($tag =~ /^<[Aa]\b/ and $tag =~ /href/i and $tag =~ /mailto:/i) {
            $tag =~ s/($address_rx)/hide_address($1)/eg;
        }
        print $tag;
    } elsif ($3) { # nontag
        $nontag = $3;
        $nontag =~ s/($address_rx)/hide_address($1)/eg;
        print $nontag;
    }
}

sub hide_address {
    my $addr = shift;
    $addr =~ s/(.+)\@.+/$1\@[HIDDEN]/;
    return $addr;
}
