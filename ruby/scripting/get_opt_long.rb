#!/usr/bin/env ruby
require 'slop'
puts 'Testing out the slop lib'
puts 'https://github.com/injekt/slop'

#
# helper that prints an error msg and cmd-line args when provided
#
def print_help(msg='empty error msg', opts=nil)
  puts msg
  puts opts if opts
end

#
# helper to get options from cmd-line (or argv)
#
def get_opts

  # Slop.parse returns the 'opts' object
  Slop.parse do
    on :n, :name=, 'a name you enter'
  end

rescue => e
  print_help e.message
  nil
end

#
# main
#
opts=get_opts
exit unless opts

opts_hash=opts.to_hash
unless opts_hash
  puts 'encountered null opts.to_hash - no bueno'
  exit
end

unless opts.name?
  print_help 'missing name arg', opts
  exit
end

puts "Name received: '#{opts_hash[:name]}'"
puts 'Done'
0
