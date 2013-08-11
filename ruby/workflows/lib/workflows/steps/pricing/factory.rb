
module Workflows
	module Steps
		module Pricing

			# return the various steps of the pricing workflow
			def self.get_steps
				[Workflows::Steps::Pricing::PricingStepOne.new]
			end
		end
	end
end
