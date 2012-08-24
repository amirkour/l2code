# to use Foo in a script:
#require './foo.rb'

# to get all the fun Enumerable module additions,
# include it here, and then make sure to implement
# .each in the class
include Enumerable

#
# here's our (very informatively named) class
#
class Foo

  # initialize is the constructor
  def initialize(new_bar)
    @bar=new_bar
  end

  # increment each letter of bar, return that new string
  def inc
    new_bar = "";
    @bar.each_char do |char| new_bar << char.succ end
    return new_bar
  end

  # increment each letter of bar in place, overwriting bar
  # w/ new string
  def inc!
    @bar=self.inc
  end

  # provide some iteration power!
  def each
    return self.enum_for(:each) unless block_given?
    return unless @bar && @bar.length > 0
    @bar.each_char do |nextChar| yield nextChar end
  end

  # and this is how you provide a getter and setter for @bar
  attr_accessor :bar

  # you could've provided read-only with attr_reader:
  #attr_reader :bar
end
