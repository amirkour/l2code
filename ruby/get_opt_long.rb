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
  print_help('there was an error while parsing cmd-line args, with the following msg: ' + e.message)
  nil
end

#
# main
#
opts=get_opts
puts 'encountered null opts' && exit unless opts

opts_hash=opts.to_hash
puts 'encountered null opts.to_hash' && exit unless opts_hash

unless(opts.name?)
	print_help('missing name arg', opts)
	exit
end

puts "Name received: '#{opts_hash[:name]}'"
puts 'Done'
0
