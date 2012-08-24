#!/home/amirk/.rvm/rubies/ruby-1.9.3-p194/bin/ruby

# w/o the ./ in the front of foo.rb, this doesn't work ...
require './foo.rb'

puts 'starting'
a=Foo.new('a-bar')
puts "a's bar is '#{a.bar}'"
a.inc!
puts "a's bar is '#{a.bar}'"
new_bar=a.inc
puts "a's bar is '#{a.bar}'"
puts "a's new bar which wasn't stored is '#{new_bar}'"
puts 'done'
