module XLUTOWIN

	DEFAULT_EXCEL_UNICODE_ENCODING="UTF-16LE"
	DEFAULT_ENCODING_TO_TRANSCODE_TO="Windows-1252"

	def self.open(excel_unicode_filename, excel_file_encoding=XLUTOWIN::DEFAULT_EXCEL_UNICODE_ENCODING, encoding_to_transcode_to=XLUTOWIN::DEFAULT_ENCODING_TO_TRANSCODE_TO, &block)
		file=File.open(excel_unicode_filename, "r:bom|#{excel_file_encoding}:#{encoding_to_transcode_to}")
		return file unless block
		begin
			block.call(file)
		ensure
			file.close
		end
	end

	def self.each_line(excel_unicode_filename, excel_file_encoding=XLUTOWIN::DEFAULT_EXCEL_UNICODE_ENCODING, encoding_to_transcode_to=XLUTOWIN::DEFAULT_ENCODING_TO_TRANSCODE_TO, &block)
		lines_as_hashes=[]
		XLUTOWIN.open(excel_unicode_filename, excel_file_encoding, encoding_to_transcode_to) do |file|
			file.each_line do |line|
				line_as_hash=line.chomp.split(/\t/)
				if block
					block.call(line_as_hash)
				else
					lines_as_hashes << line_as_hash
				end
			end
		end

		return lines_as_hashes unless block
	end
end

# usage 1
# file=XLUTOWIN.open("filename")

# usage 1 w/ block
# XLUTOWIN.open("filename") do |file|
# end

# usage 2
# all_lines=XLUTOWIN.each_line(filename)

# usage 2 w/ block
# XLUTOWIN.each_line(filename) do |line|
# end