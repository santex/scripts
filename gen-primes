#!/usr/bin/ruby

# 040424

if ARGV.length != 1
  puts "Usage: #{$0} <n>, where <n> is the number of primes you want"
  exit
end

n = ARGV[0].to_i
i = 1
num = 2

while i <= n
  if i==1
    #puts "2 is prime"
    puts num; num += 1; i += 1
  elsif i==2
    #puts "3 is prime"
    puts num; num += 2; i += 1
  else
    j = 2
    m = Math.sqrt(num).to_i + 1
    #puts "testing whether #{num} is prime (#{j}..#{m})"
    
    while j <= m
      #puts "  #{num} % #{j} = #{num % j}"
      if num % j == 0
        #puts "  #{num} is divisible by #{j}, not prime"
        break
      else
        j += 1
      end
    end
  
    if j > m
      #puts "  #{num} is prime"
      puts num; i += 1
    end
    num += 2
  end
  
end
