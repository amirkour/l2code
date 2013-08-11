# todo - fix the includes and references
require './steps/pricing/verifications/PricingStepOne.rb'

module WorkflowsSteps
	module WorkflowsSteps_Pricing

		# return the various steps of the pricing workflow
		def self.get_steps
			[PricingStepOne.new]
		end
	end	
end
