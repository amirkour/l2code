module XLUTOWIN

	DEFAULT_EXCEL_UNICODE_ENCODING=Encoding.find("UTF-16LE") || nil
	DEFAULT_ENCODING_TO_TRANSCODE_TO=Encoding.find("Windows-1252") || nil

	# opens the given file for reading under the assumption that it's encoded in utf-16le and has a BOM to that effect,
	# transcoding to windows-1252.
	#
	# returns the file handle if no block given, otherwise yields the resulting file handle to the given block.
	def self.open(excel_unicode_filename, excel_file_encoding=XLUTOWIN::DEFAULT_EXCEL_UNICODE_ENCODING, encoding_to_transcode_to=XLUTOWIN::DEFAULT_ENCODING_TO_TRANSCODE_TO, &block)
		if(excel_file_encoding.is_a?(String))
			encoding_name=excel_file_encoding
			excel_file_encoding=Encoding.find(excel_file_encoding)
			raise "Unrecognized encoding #{encoding_name}" unless excel_file_encoding
		end

		if(encoding_to_transcode_to.is_a?(String))
			encoding_name=encoding_to_transcode_to
			encoding_to_transcode_to=Encoding.find(encoding_to_transcode_to)
			raise "Unrecognized encoding #{encoding_name}" unless encoding_to_transcode_to
		end
		
		file=File.open(excel_unicode_filename, "r:bom|#{excel_file_encoding.to_s}:#{encoding_to_transcode_to.to_s}")
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
				end

				line_hash={}
				line_columns.each_index do |i|
					col_value=line_columns[i].strip
					line_hash[col_headers[i]]=(col_value.empty?) ? nil : col_value
				end

				if block
					block.call(line_hash)
				else
					rows_as_hashes << line_hash
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