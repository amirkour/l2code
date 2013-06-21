require './Mongodoc.rb'

# workflows have a type, and are factories for workflow items of the same type.
# they're generated by WorkflowType objects
class Workflow < Mongodoc

	attr_accessor :name		# every workflow has a name, like 'db biotech update'
	attr_accessor :type 	# every workflow has a type, derived from the WorkflowType that created it
end