#!/usr/bin/env /cygdrive/d/Ruby193/bin/ruby

#
# gets a PDF from http url and writes it out to file
#

require 'open-uri'
require 'pp'

strFileName='write.pdf'
#pPdf=nil

begin

	# the call to 'open' is going to open-uri, but i can't find that api anywhere in the docs :(
	# i guess you just have to require 'open-uri' and then go-with-god
	pPdf=open("http://www.monosan.com/media/doc.aspx?id=94409e3b-c5ba-450d-a8b8-8290ae94845f&f=1010.pdf");
	File.open(strFileName, "w+b"){ |fileToWriteTo|
		fileToWriteTo.write(pPdf.read);
	}
ensure
	if (pPdf and !pPdf.closed?)
		pPdf.close()
		puts "closed pdf thingey"
	end
end
puts "done"
0
