#!/usr/bin/ruby

# 2006-01-03

# Step 1: Double the value of alternate digits of the primary account
# number beginning with the second digit from the right (the first
# right--hand digit is the check digit.)  Step 2: Add the individual
# digits comprising the products obtained in Step 1 to each of the
# unaffected digits in the original number.
#
# Step 3: The total obtained in Step 2 must be a number ending in zero
# (30, 40, 50, etc.) for the account number to be validated.
#
# For example, to validate the primary account number 49927398716:
#
# Step 1:
#
#        4 9 9 2 7 3 9 8 7 1 6
#         x2  x2  x2  x2  x2 
#------------------------------
#         18   4   6  16   2
#
# Step 2: 4 +(1+8)+ 9 + (4) + 7 + (6) + 9 +(1+6) + 7 + (2) + 6 
#
# Step 3: Sum = 70 : Card number is validated 
#
# Note: Card is valid because the 70/10 yields no remainder.

def to1(n)
  while n > 9
    x = 0
    n.to_s.each_byte {|b| x += b.chr.to_i}
    n = x
  end
  n
end

def check_luhn(arg)
  tot = 0
  i = 1
  arg.reverse.each_byte {|b|
    tot += ((b % 2 == 0) ? 1 : 2) * b.chr.to_i
    i += 1
  }
  tot % 10 == 0
end

if ARGV.length == 0
  puts "Usage: #{0} <number>"
  exit
end

ARGV.each {|arg|
  puts "#{arg}: #{check_luhn(arg) ? 'check' : 'fail'}"
}

# test: 49927398716, 
