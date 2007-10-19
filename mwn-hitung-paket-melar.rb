#!/usr/bin/ruby

if ARGV.length != 1
  puts "Usage: #$0 <n>, where n is the number of month"
  exit 0
end

n = ARGV[0].to_i

[100, 200, 400, 1000, 2000, 4000, 8000].each { |p|
  puts "#{p}: #{sprintf '%.1f', p*(1.0+n/36.0)}"
}
