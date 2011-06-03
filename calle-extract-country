#!/usr/bin/perl

# 20040807 - extract informasi dari hasil download
# http://www.calle.com/world/<2lettercountry>/. jalankan skrip ini dari
# subdirektori <2lettercountry>/ hasil download.

$VERBOSE = 1;
$SEP = "\t";

sub verbose {
  return unless $VERBOSE;
  print STDERR "VERBOSE: ", @_, "\n";
}

#
# extract list of provinces
#

verbose "Parsing list of provinces...";
open F, "index.html" or die "FATAL: Can't open index.html: $!\n";
$_ = join "", <F>;
close F;

/Directory of Cities, Towns, and Regions in / or die "FATAL: file `index.html': Doesn't seem to be a valid provinces list page (no signature string)\n";

%provinces = (); # dirname => province name
%cities = (); # "prov_id.city_name" => {name=>..., aliases=>[...], lat=>..., lon=>..., alt=>..., tz=>..., dst=>(1 or 0)}

while (m!^<li><a href="?(?:/world/[A-Z][A-Z]/)?(\d+)/(?:index.html)?"?>(.+?)</a></li>!mg) {
  $provinces{$1} = $2;
}

verbose((scalar keys %provinces), " provinces found");

#
# extract every city from every province
#

for $prov_id (keys %provinces) {
  verbose "Entering $prov_id/ ($provinces{$prov_id})...";
  chdir $prov_id or die "FATAL: Can't chdir to $prov_id/ ($provinces{$prov_id}: $!\n";
  
  for $file (<*>) {

    #next unless $file =~ /\.html?/;
    next if $file eq 'index.html';
    
    open F, $file or die "FATAL: Can't open `$prov_id/$file: $!\n";
    $_ = join "", <F>;
    close F;
    
    /Falling Rain Genomics/ or die "FATAL: file `$prov_id/$file': Doesn't seem to be a valid city page (no copyright signature)\n";

    my $info = {};
    
    # name
    m!<H1>(.+?), ! or die "FATAL: file `$prov_id/$file': No name?\n";
    $info->{name} = $1;
    
    # aliases
    if (m!^<h3>Other names: (.+?)</h3>!m) {
      $othernames = $1;
      $info->{aliases} = [split /,\s*/, $othernames];
    } else {
      $info->{aliases} = [];
    }
    
    # latitude
    m!<th>Latitude<td>([+-]?\d*(\.\d+)?)<! or die "FATAL: file `$prov_id/$file': No latitude?\n";
    $info->{lat} = $1+0.0;
    
    # longitude
    m!<th>Longitude<td>([+-]?\d*(\.\d+)?)<! or die "FATAL: file `$prov_id/$file': No longitude?\n";
    $info->{lon} = $1+0.0;

    # altitude (meters)
    m!<th>Altitude \(meters\)<td>([+-]?\d*(\.\d+)?)<! or die "FATAL: file `$prov_id/$file': No altitude (feet)?\n";
    $info->{alt} = $1+0.0;

    # timezone
    if (m!<th>Time zone \(est\)<td>UTC([+-]\d\d?)(?::(\d\d))?(\([+-]\d\d?(?::\d\d)?DT\))?<!) {
    
      $info->{tz} = $1 + ($2 ? $2/60.0 : 0.0);
      $info->{dst} = $3 ? 1:0;
    } elsif (m!<th>Time zone \(est\)<!) {
      $info->{tz} = $info->{dst} = '?';
    }else {
      die "FATAL: file `$prov_id/$file': No timezone field?\n";
    }
    
    $cities{sprintf("%04d.%s", $prov_id, $info->{name})} = $info;
    
  }
  
  chdir ".." or die "FATAL: Can't chdir ..: $!\n";
}

#use Data::Dumper;
#print Dumper \%cities;

#
# print result
#

print
  "#PROVINCEID", $SEP,
  "PROVINCENAME", $SEP,
  "CITYNAME", $SEP,
  "LAT", $SEP,
  "LON", $SEP,
  "ALT", $SEP,
  "TZ", $SEP,
  "DST?", $SEP,
  "ALIAS...", "\n";

for (sort keys %cities) {
  ($prov_id) = /(\d+)\./;
  $prov_id+=0;
  $city = $cities{$_};
  
  print
    $prov_id, $SEP,
    $provinces{$prov_id}, $SEP,
    $city->{name}, $SEP,
    $city->{lat}, $SEP,
    $city->{lon}, $SEP,
    $city->{alt}, $SEP,
    $city->{tz}, $SEP,
    $city->{dst};
 
  if (@{ $city->{aliases} }) {
    print $SEP;
    print join $SEP, @{ $city->{aliases} };
  }
  
  print "\n";
  
}
