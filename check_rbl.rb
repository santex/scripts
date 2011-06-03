#!/usr/bin/ruby

# 2004-12-11

rbls = {
  'spamcop' => 'bl.spamcop.net',
  'spamhaus' => 'sbl-xbl.spamhaus.org',
  'sorbs' => 'dul.dnsbl.sorbs.net',
  'dsbl' => 'list.dsbl.org',
  'rfc-ignorant.org' => 'dsn.rfc-ignorant.org',
  'antispam.or.id' => 'dnsbl.antispam.or.id',
}

if ARGV.length == 0
  puts "Usage: check_rbl.rb <ip-address> ..."
  exit 0
end

ARGV.each {|ip|
  unless ip =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/
    puts "ERROR: Bad IP syntax `#{ip}', skipped"
    next
  end
  revip = "#{$4}.#{$3}.#{$2}.#{$1}"
  rbls.each_pair {|rblname, rbl|
    print "Checking #{ip} with #{rblname} (`host #{revip}.#{rbl}')... "
    result = %x(host #{revip}.#{rbl})
    case result
    when /connection timed out/
      puts "TIMEOUT (maybe you should try again?)"
    when /not found: 3\(NXDOMAIN\)/
      puts "not listed"
    when /127\.0\.0\./
      puts "LISTED!"
    else
      puts "ERROR, unknown response (#{result})"
    end
  }
}
