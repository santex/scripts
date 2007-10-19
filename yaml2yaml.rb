#!/usr/bin/ruby

require 'yaml'

$/ = nil
$_ = gets

puts YAML::load($_).to_yaml(:SortKeys => true)

