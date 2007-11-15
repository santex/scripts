#!/usr/bin/perl

# turns html into js that will reconstruct the html, e.g.: "<b>hi</b>" -> "<script>document.write('<b>hi</b>');</script>"
# 030111 - sh

print jsify(join "", <>);

sub jsify {
    my $html = shift;
    my @lines = ();
    for (split /\015?\012/, $html) {
        $lines[-1] .= "+\n" if @lines;
        s/(['\\])/\\$1/g;
        s#(</?scr)(ipt)#$1'+'$2#ig;
        push @lines, "'$_\\n'";
    }
    "<script>document.write(" . join("", @lines) . ");</script>\n";
}
