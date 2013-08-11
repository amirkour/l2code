require 'mongooz'
Mongooz.defaults(:db=>'workflows')

require 'workflows/workflow_base.rb'
require 'workflows/status/workflow_status.rb'

require 'workflows/workflow_objects.rb'
