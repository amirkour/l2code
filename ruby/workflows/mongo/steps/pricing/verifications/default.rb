

# this class provides support and helpers for all verifications of the pricing workflow.
# when you want to add a verification step to the pricing workflow,
# have it derive from this class, and you'll inherit it's support functions
# and helpers
class EmptyPricingVerification

	# will do some validation on the incoming item, and then delegate to your class
	def validates?(item_to_validate)
		raise "Pricing workflow verifications cannot validate nil item" if item_to_validate.nil?
		raise "Pricing workflow verifications cannot validate non-hash items" unless item_to_validate.kind_of?(Hash)
		raise "Pricing workflow verifications cannot validate non-pricing items" unless item_to_validate[:type]=='pricing'
		validates_delegate(item_to_validate)
	end

	# implement this function in your pricing verification steps
	def validates_delegate(item)
		class_name=self.class.name || "unknown pricing verification class"
		raise "Pricing verification #{class_name} has not implemented delegate validation function"

		# in your implementation, you're gonna wanna return true or false to indicate
		# whether the given item validates or not
	end
end
