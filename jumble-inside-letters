#!/usr/bin/perl -lp

# 030920

# "Aoccdrnig to a rscheearch at Cmabrigde Uinervtisy, it deosn't mttaer in
# waht oredr the ltteers in a wrod are, the olny iprmoetnt tihng is taht the
# frist and lsat ltteer be at the rghit pclae. The rset can be a total mses
# and you can sitll raed it wouthit porbelm. Tihs is bcuseae the huamn mnid
# deos not raed ervey lteter by istlef, but the wrod as a wlohe. Fcuknig
# amzanig huh?"

# "Coba tes apakah anda masih bisa membaca kata-kata di paragraf ini dengan
# lancar. Menurut sebuah penelitian di Universitas Cambridge, kita membaca
# terutama dengan memperhatikan huruf awal dan akhir tiap kata, sehingga
# meskipun urutan huruf-huruf di antaranya dibalik-balik, kita tidak
# mengalami terlalu banyak kesulitan memahaminya. Hebat bukan?"

s/\b(\w)(\w+)(\w)\b/$1.jumble($2).$3/eg;

sub jumble {
  my $word = shift;
  my @letters = $word =~ /(.)/g;
  for (1..@letters) {
    my $i = int(rand @letters);
    my $j = int(rand @letters);
    next if $i==$j;
    ($letters[$i], $letters[$j]) = ($letters[$j], $letters[$i]);
  }
  join "", @letters;
}
