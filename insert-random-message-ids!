#!/usr/bin/perl -0777 -lpi
s/^(From .+?\015?\012\015?\012)/rep($1)/mseg;
sub rep {
    local $_=shift;
    s/\n/\nMessage-ID: <${\(rand)}\@localhost>\n/ if not /^Message-ID:/m;
    return $_;
}
