#!/usr/bin/ruby

Dir.open(".").each { |f| 
  next unless FileTest.file? f
  File.unlink f
}
