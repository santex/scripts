#!/usr/bin/ruby

if ARGV.length != 2
  $stderr.puts "Usage: #{$0} filename1 filename2"
end

i = 0
begin
  tmpname = ARGV[0] + ".tmp" + (i > 0 ? ".#{i}" : "")
  i += 1
end while File.exists? tmpname

File.rename ARGV[0], tmpname
File.rename ARGV[1], ARGV[0]
File.rename tmpname, ARGV[1]
