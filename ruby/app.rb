# coding: Windows-1252


# read a file encoded in utf16-le (which is what excel outputs when you save as unicode) and write it to a file in utf-8
# read the utf-8 file and write it to a file in windows-1252

puts "default external is #{Encoding.default_external}"
puts "default internal is #{Encoding.default_internal}"

in_file_utf16le='utf16le.txt'
out_file_utf8='out_utf8.txt'
out_file_win1252='out_win1252.txt'

in_utf16le=nil
in_utf8=nil
out_utf8=nil
out_win1252=nil
begin
	puts "writing from utf-16le to utf-8"
	in_utf16le=File.open(in_file_utf16le, "r:bom|UTF-16LE:utf-8")
	out_utf8=File.open(out_file_utf8, "w:utf-8")
	in_utf16le.each_line do |line|
		begin
			out_utf8.write(line)
		rescue Encoding::UndefinedConversionError
			puts $!.error_char.dump
			puts $!.error_char.encoding
		end
	end
	in_utf16le.close
	in_utf16le=nil
	out_utf8.close
	out_utf8=nil

	puts "writing from utf-8 to win1252"
	in_utf8=File.open(out_file_utf8, "r:utf-8:Windows-1252")
	out_win1252=File.open(out_file_win1252,"w:Windows-1252")
	in_utf8.each_line do |line|
		out_win1252.write(line)
	end
	out_win1252.close
	out_win1252=nil
	in_utf8.close
	in_utf8=nil

ensure
	out_utf8.close unless out_utf8.nil?
	out_win1252.close unless out_win1252.nil?
	in_utf8.close unless in_utf8.nil?
	in_utf16le.close unless in_utf16le.nil?
end
