
# this module is expected to be mixed into objects of type Workflows::WorkflowBase
# so that you can do something like
# cool_workflow_object = WorkflowBaseChildWithStatusMixedIn.new
# cool_workflow_object.ready!        <- should immediately persist with status 'ready'
# cool_workflow_object.processing?   <- returns false
# cool_workflow_object.processing    <- sets status to processing, but does not persist
module Workflows
	module Status

		STATUS_LIST=%w(ready processing error complete)

		def method_missing(method_name_as_symbol, *args)
			super unless self.kind_of?(Workflows::WorkflowBase)

			method_name_as_s=method_name_as_symbol.to_s

			# obj.ready?
			just_asking=method_name_as_s.end_with?('?')

			# obj.ready!
			persist_now=method_name_as_s.end_with?('!')

			actual_method_name=(just_asking || persist_now) ? method_name_as_s.chop : method_name_as_s
			super unless Workflows::Status::STATUS_LIST.include?(actual_method_name)
			
			# return true or false for obj.ready?
			return self[:status]==actual_method_name if just_asking

			self[:status]=actual_method_name
			
			if persist_now
				super unless self.respond_to?(:db_save)
				successful=self.db_save
				raise "Could not save status" unless successful
				return successful
			end

			self
		end	
	end
end
