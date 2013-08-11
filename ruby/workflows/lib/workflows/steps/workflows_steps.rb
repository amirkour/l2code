
module Workflows
	module Steps

		# factory method that maps a given workflow type to a set of verifcation
		# steps.
		#
		# example usage:
		# steps = Workflows::Steps.get_steps('pricing')
		# steps.each do |x|
		#   x.validates?(workflow item hash)
		# end
		def self.get_steps(type)
			factory_module=case type
							when 'import' 
								Workflows::Steps::Default # currently unsupported
							when 'pricing'
								Workflows::Steps::Pricing
							else
								Workflows::Steps::Default
							end

			# your module has to define this method, and it's expected
			# to return a list of objects that implement validates?(WorkflowHash)
			factory_module.get_steps
		end

		# this is just an empty module to return as a stand-in.  when callers
		# request verification steps for a workflow type that doesn't exist,
		# this module will stand in and return an empty list of verification
		# steps back to the caller
		module Default
			def self.get_steps
				[]
			end
		end
	end
end
