# coding: utf-8


str="i'm a string"
puts "__ENCODING__ variable is #{__ENCODING__}"
puts "strings are encoded as #{str.encoding}"
puts "default external is #{Encoding.default_external}"
puts "default internal is #{Encoding.default_internal}"

#File.open("in.txt", "r:#{__ENCODING__}") do |file|
File.open("in.txt", "r") do |file|
	file.each_line do |line|
		new_line=line + " my own addition"
		puts "File line encoding is #{line.encoding}"
		puts "new_line encoding is #{new_line.encoding}"
		
	end
end

#
# source encoding
#
# the encoding that ruby uses to interpret the characters of a ruby file/script.
# the default source encoding depends on the system's locale and you can get it
# with the variable __ENCODING__
# you can set the source encoding with the following comment as the first line of your file
# coding: utf-8
# the source encoding of the file affects the encoding of string literals in that file.
# you also can't just willy-nilly set the encoding of your file - if you try to set the
# encoding of a .rb file to utf-8 but it's an ascii file, ruby is smart enough to detect
# this and will barf (so use sublime to save the file in the right encoding.)
# note that every file in a ruby program can have a different source encoding, which
# will affect strings vended out of the API of that file!  if two files w/ incompatible
# encodings try to talk to each other, you're in for a world of hurt ...

#
# external encoding
#
# the external encoding is the encoding that ruby uses for data incoming from external
# sources/streams (like network io, file io, etc.)
# you can see what it defaults to (again, based on system and locale) via
# Encoding.default_external
# and you can set it via command-line args when you run an app
# ruby -E utf-8 foo.rb
# if you try to read in strings from a file w/ external encoding X, and concatenate
# to strings in a file with encoding Y, and the encodings X and Y are incompatible,
# ruby will barf b/c it can't transcode from X to Y!

#
# internal encoding
#
# will normally default to the external encoding (i think?)
# when a ruby program reads text from a file or network socket, it normally leaves the
# text in its native encoding (and by 'native encoding' i mean, the encoding of the data
# in/from the file - note that if ruby cannot detect what that is, it will use 
# Encoding.default_external.)
# if you prefer to have all text automatically transcoded 
# to a single common encoding, you can specify a default internal encoding

# to query the default external and internal encodings, use Encoding.default_external and
# Encoding.default_internal.