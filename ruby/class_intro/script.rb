#!/home/amirk/.rvm/rubies/ruby-1.9.3-p194/bin/ruby

# w/o the ./ in the front of foo.rb, this doesn't work ...
require './foo.rb'

puts 'starting'
a=Foo.new('a-bar')
puts "a's bar is '#{a.bar}'"
a.inc!
puts "after call to inc! - a's bar is '#{a.bar}'"
new_bar=a.inc
puts "after call to inc - a's bar should still be the same - it's now: '#{a.bar}'"
puts "and the last call to inc should be different - it's: '#{new_bar}'"

puts ""
puts "testing foo.each ... should iterate on letters of bar, which are currently: '#{a.bar}'"
a.each do |nextCharOfBar|
  puts "next char of bar is: '#{nextCharOfBar}'"
end

puts ""
puts "calling foo.each w/o a block - should just get back an enum..."
begin
  supposed_enum=a.each

  if supposed_enum
    puts "got back something from foo.each w/o a block: '#{supposed_enum.inspect}'"
    puts "iterating on the enum now ... it should just print the letters of a.bar again ..."
    supposed_enum.each do |nextCharOfBar|
      puts "#{nextCharOfBar}"
    end
  else
    puts "no enum returned for foo.each call w/o a block!"
  end
rescue => e
  puts "while calling foo.each w/o a block, got the following error: '#{e.message}'"
end

puts ""
puts "gonna test some of the 'enumerable' module tidbits ..."
puts "will filter out all vowels with the .reject helper ..."
a.bar << 'awiov'
puts "first, add some vowels - here's what bar is now: '#{a.bar}";
puts "and here's the list returned from 'rejecting' vowels:"
vowels=%w{a e i o u}
filtered=a.reject do |potentialVowel| vowels.include? potentialVowel end
filtered.each do |x| puts "#{x}" end
puts "But bar should still be the same!  here it is: '#{a.bar}'"


puts ""
puts 'done'
