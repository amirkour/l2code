module XLUTOWIN

	DEFAULT_EXCEL_UNICODE_ENCODING="UTF-16LE"
	DEFAULT_ENCODING_TO_TRANSCODE_TO="Windows-1252"

	# opens the given file for reading under the assumption that it's encoded in utf-16le and has a BOM to that effect,
	# transcoding to windows-1252.
	#
	# returns the file handle if no block given, otherwise yields the resulting file handle to the given block.
	def self.open(excel_unicode_filename, excel_file_encoding=XLUTOWIN::DEFAULT_EXCEL_UNICODE_ENCODING, encoding_to_transcode_to=XLUTOWIN::DEFAULT_ENCODING_TO_TRANSCODE_TO, &block)
		file=File.open(excel_unicode_filename, "r:bom|#{excel_file_encoding}:#{encoding_to_transcode_to}")
		return file unless block
		begin
			block.call(file)
		ensure
			file.close
		end
	end

	# opens the given file for reading under the assumption that it's encoded in utf-16le and has a BOM to that effect,
	# transcoding to windows-1252.
	#
	# also assumes that the lines of the given file are tab-delimited and end with a crlf (standard stuff for an excel
	# file saved as 'unicode' text.)
	#
	# returns a list if no block given - the list contains each row as a list (the row as columns.)
	# if a block is given, yields each row as a list (the row as columns) to the block.
	def self.lines_as_cols(excel_unicode_filename, excel_file_encoding=XLUTOWIN::DEFAULT_EXCEL_UNICODE_ENCODING, encoding_to_transcode_to=XLUTOWIN::DEFAULT_ENCODING_TO_TRANSCODE_TO, &block)
		lines_as_cols=[]
		XLUTOWIN.open(excel_unicode_filename, excel_file_encoding, encoding_to_transcode_to) do |file|
			file.each_line do |line|
				line_columns=line.chomp.split(/\t/)
				if block
					block.call(line_columns)
				else
					lines_as_cols << line_columns
				end
			end
		end

		return lines_as_cols unless block
	end
end

# usage 1
# file=XLUTOWIN.open("filename") <- file is now open for reading, and will transcode to windows-1252

# usage 1 w/ block
# XLUTOWIN.open("filename") do |file|
# end

# usage 2
# all_lines=XLUTOWIN.lines_as_cols(filename)

# usage 2 w/ block
# XLUTOWIN.lines_as_cols(filename) do |line_as_columns|
# 	puts line_as_columns[0]
# 	puts line_as_columns[1]
# 	etc ...
# end