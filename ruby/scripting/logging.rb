#!/Users/amirk/.rvm/rubies/ruby-1.9.3-p194/bin/ruby

#l2code log4r
#gem install -r log4r
#
require 'log4r'
require 'log4r/configurator'
include Log4r

# substitute the 'logpath' variable into the log configuration
Configurator['logpath']="path/to/output"
Configurator.load_xml_file('log4r_config.xml')
logger = Logger['appLogger']

logger.debug 'debug msg'
logger.error 'error msg'

p "hi"
