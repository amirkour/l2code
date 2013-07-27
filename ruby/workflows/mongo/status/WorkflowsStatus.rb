


# this module is expected to be mixed into objects of type WorkflowHash
module WorkflowsStatus

	STATUS_LIST=%w(ready processing error complete)

	def method_missing(method_name, *args)
		puts "method_missing called in WorkflowsStatus module"
		super
	end	
end

