#!/usr/bin/perl

# 031210 - buat bikin index buku dian rakyat (buku seri resep pemrograman)
#
# input is like this (fields are separated by tabs):
#
# name                        id   cat  category_name      keywords
# Mengambil Kurs              2-1  2    Memperoleh Data    kurs; dolar; rupiah; Yahoo!
# Mengambil Headline Berita   2-2  2    Memperoleh Data    berita; headline berita; detik.com; kompas.com; news; news headline
# ...
#
# and output is an index page (HTML page containing keywords along with the recipe id)

# 040108 - simbol

%keywords = (); # key = lc(keyword), value={keyword=>keyword, sortword=>sortword, recipes=>[recipe_id, ...]}

# string yang dipakai untuk sorting
sub sortword {
  local $_ = lc shift;
  s/(?<=.)[^A-Za-z0-9]+//g;
  /^[^A-Za-z]/ ? "_" : $_;
}

$i=0;
while (<>) {
  next if !$i++;
  chomp;
  ($name, $id, $cat, $category_name, $keywords) = split /\t/, $_;
  @keywords = grep {/\S/} split /;\s*/, $keywords;
  
  for (@keywords) {
    $lc = lc $_;
    if (!exists $keywords{$lc}) {
      $keywords{$lc}{keyword} = $_;
      $keywords{$lc}{sortword} = sortword($_);
    }
    push @{ $keywords{$lc}{recipes} }, $id
  }
}

print "<h1>Indeks</h1>\n";
print "<table border=0 width=50%>";

# XXX symbol

for $section ("_", "a".."z") {
  print "\n<tr><td colspan=2>&nbsp;</td></tr>\n";
  print "<tr><td colspan=2><b>",($section eq '_' ? "Simbol" : uc($section)),"</b></td></tr>\n";
  for (sort {$keywords{$a}{sortword} cmp $keywords{$b}{sortword}}
       grep {substr($keywords{$_}{sortword},0,1) eq $section} keys %keywords) {
    print "  <tr><td width=50%>$keywords{$_}{keyword}</td><td>${\( join ', ', @{ $keywords{$_}{recipes} } )}</td></tr>\n";
  }
}

print "</table>\n";
