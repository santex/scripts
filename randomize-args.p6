#!/usr/bin/perl6

# rakudo belum support sintaks hyperoperator?
#sub prefix:<quote>($s) { "'" ~ $s.subst("'", "'\"'\"'") ~ "'" }
#sub MAIN(*@argv) {
#    say (quote<< @argv).pick(*).join(" ");
#}

# boring version
sub quote($s) { "'" ~ $s.subst("'", "'\"'\"'") ~ "'" }
sub MAIN(*@argv) {
    say (map {quote($_)}, @argv).pick(*).join(" ");
}

