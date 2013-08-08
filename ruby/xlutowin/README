xlutowin -> Excel Unicode To Windows
When you save files in excel as 'unicode', it writes out a tab-delimited text file in utf-16le with BOM.

More often than not, I'm parsing such files and sending the resulting data to a sql2008 table with
windows-1252 as the standard table encoding.  

This library takes a filename (expected to be an excel 'unicode' file) and transcodes to windows-1252,
so that I don't keep having to memorize and/or lookup this line of code:
file=File.open("name of unicode file.txt", "r:bom|utf-16le:windows-1252")

Hurray!
