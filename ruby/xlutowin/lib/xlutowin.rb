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

	# opens the given file for reading under the assumption that
	# 1. it's encoded in utf-16le and has a BOM to that effect,
	# 2. needs to be transcoded to windows-1252,
	# 3. the lines of the given file are tab delimited and end with crlf,
	# 4. the first row of the file is column headers
	#
	# standard stuff for an excel file that's saved as 'unicode'
	#
	# returns a list if no block given - the list contains each row as a hash (the row as columns.)
	# if a block is given, yields each row as a hash (the row as columns) to the block.
	#
	# the keys of the resulting hashes are just the column headers (taken from the first row of the file)
	# where whitespace is replaced with "_" and then converted to symbols.  IE, the following first row:
	# foo\tbar and baz\tbla
	#
	# would result in the following hash keys for each row:
	# :foo
	# :bar_and_baz
	# :bla
	def self.each_row(excel_unicode_filename, excel_file_encoding=XLUTOWIN::DEFAULT_EXCEL_UNICODE_ENCODING, encoding_to_transcode_to=XLUTOWIN::DEFAULT_ENCODING_TO_TRANSCODE_TO, &block)
		rows_as_hashes=[]

		XLUTOWIN.open(excel_unicode_filename, excel_file_encoding, encoding_to_transcode_to) do |file|
			first_row=true
			col_headers=[]
			file.each_line do |line|
				line_columns=line.chomp.split(/\t/)

				# assume first row is column headers
				if(first_row)
					first_row=false
					line_columns.each do |header|
						col_headers << header.gsub(/\s+/,"_").downcase.intern
					end
					next
				else
					line_hash={}
					line_columns.each_index do |i|
						line_hash[col_headers[i]] = line_columns[i]
					end

					if block
						block.call(line_hash)
					else
						rows_as_hashes << line_hash
					end
				end
			end
		end

		return rows_as_hashes unless block
	end
end

# usage 1
# file=XLUTOWIN.open("filename") <- file is now open for reading, and will transcode to windows-1252

# usage 1 w/ block
# XLUTOWIN.open("filename") do |file|
# end

# usage 2
# all_lines=XLUTOWIN.each_row(filename)

# usage 2 w/ block
# XLUTOWIN.each_row(filename) do |row_as_hash|
# 	puts row_as_hash[:col_header_one]
# 	puts row_as_hash[:col_header_two]
# 	etc ...
# end