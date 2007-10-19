#!/usr/bin/perl

# 20040808 - jalankan skrip ini di direktori berisi sekumpulan file *.gif.
# maka skrip ini akan membuat subdir html/ berisi.

unless (-d "html") {
  mkdir "html", 0755 or die "FATAL: Can't make html/ subdir: $!\n";
}

@gifs = sort <*.gif>;
for (@gifs) { s/\.gif$//; }

for $i (0..$#gifs) {
  $g = $gifs[$i];
  
  open F, ">html/$g.html";
  
  $title = "$g (${\($i+1)} of ${\(scalar @gifs)})";
  print F "<title>$title</title><h3>$title</h3>\n";
  
  $nav = "<p>";
  for $j (-100, -50, -40, -30, -20, -15, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1) {
    $nav .= ($i+$j >= 0 ? " <a href=${\($gifs[$i+$j])}.html>$j</a> " : " $j ");
  }
  $nav .= " &nbsp; <a href=index.html>Index</a> &nbsp; ";
  for $j (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 30, 40, 50, 100) {
    $nav .= ($i+$j < @gifs-1 ? " <a href=${\($gifs[$i+$j])}.html>+$j</a> " : " +$j ");
  }
  $nav .= "</p>\n";
  
  print F $nav;
  print F "<img border=0 src='../$g.gif'>\n";
  print F $nav;
  
  close F;
}

open F, ">html/index.html";
print F "<ol>\n";
for $i (0..$#gifs) {
  print F "  <li><a href=$gifs[$i].html>$gifs[$i]</a>\n";
}
print F "</ol>\n";
close F;
