#!/usr/bin/ruby

# 040319 - first write. formula didapat dari XXX
# TODO - menggunakan informasi dari www.calle.com yang telah diekstrak ke file /home/steven/e/etc/city-id.txt

Circumference = 40123.648 # km
Deg2Rad = Math::PI / 180.0

def distance2places(lat1, lon1, lat2, lon2) # all in degrees
  lat1 *= Deg2Rad; lon1 *= Deg2Rad; lat2 *= Deg2Rad; lon2 *= Deg2Rad
  
  cosarc = Math::sin(lat1) * Math::sin(lat2) +
           (Math::cos(lat1) * Math::cos(lat2) * Math::cos(lon1-lon2))
  arc    = (Math::atan(-cosarc / (-cosarc**2+1)**0.5) + 2*Math::atan(1))/Deg2Rad
           
  arc/360.0 * Circumference # km
end

Cities = {
  # name            => [lat, lon]; in degrees, - = west, south; + = east, north
  'bandung'         => [-  6.91, +107.60],
  'jakarta'         => [-  6.18, +106.83],
}

if ARGV.length != 2
  puts "Usage: #{$0} <city1> <city2>"
  exit
end

if !Cities[ARGV[0].downcase]
  puts "FATAL: Unknown city '#{ARGV[0]}'"
  exit 1
else
  lat1, lon1 = Cities[ARGV[0].downcase]
end

if !Cities[ARGV[1].downcase]
  puts "FATAL: Unknown city '#{ARGV[1]}'"
  exit 1
else
  lat2, lon2 = Cities[ARGV[1].downcase]
end

printf "%d km\n", distance2places(lat1, lon1, lat2, lon2)
