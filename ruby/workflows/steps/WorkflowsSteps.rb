
# require './import/WorkflowsSteps_Import.rb'
require './steps/pricing/WorkflowsSteps_Pricing.rb'

module WorkflowsSteps

	# factory method that maps a given workflow type to a set of verifcation
	# steps.
	#
	# example usage:
	# steps = WorkflowsSteps.get_steps_for_workflow('pricing')
	# steps.each do |x|
	#   x is an implementation of DefaultVerification ...
	# end
	def self.get_steps(type)
		module_to_ret=case type
						when 'import' 
							WorkflowsSteps::WorkflowsSteps_Default # currently unsupported
						when 'pricing'
							WorkflowsSteps::WorkflowsSteps_Pricing
						else
							WorkflowsSteps::WorkflowsSteps_Default
						end

		# your module has to define this method, and it's expected
		# to return a list of objects that implement validates?(WorkflowHash)
		module_to_ret.get_steps
	end

	# this is just an empty module to return as a stand-in.  when callers
	# request verification steps for a workflow type that doesn't exist,
	# this module will stand in and return an empty list of verification
	# steps back to the caller
	module WorkflowsSteps_Default
		def self.get_steps
			[]
		end
	end

	
end
