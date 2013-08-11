module Workflows

	class WorkflowTypes < Workflows::WorkflowBase

		alias_method :original_db_save, :db_save
		def db_save(options={})
			ensure_hash_has_symbol(self, :_id)
			original_db_save(options)
		end

		# generate a new workflow object.  each workflow has to have
		# a 'type' (which is the _id of this object) and an _id that
		# is basically the name of the workflow (like 'really cool workflow')
		def new_workflow(new_workflow_name)
			ensure_hash_has_symbol(self, :_id)

			this_workflow_type=WorkflowTypes.db_get_with_id :_id=>self[:_id]
			raise "Cannot generate workflows for a non-existing workflow type - have you committed this workflow type to db yet?" if this_workflow_type.nil?

			wf=Workflowz.new
			wf.update :_id=>new_workflow_name, :type=>self[:_id]
			wf
		end

		# generate a new workflow object and immediately commit it to DB
		def new_workflow!(new_workflow_name)
			wf=new_workflow(new_workflow_name)
			raise "Could not save new workflow to db" unless wf.db_save
			wf
		end

		# TODO - each_step function and integration w/ WorkflowsSteps.get_steps
	end

	class Workflowz < Workflows::WorkflowBase
		alias_method :original_db_save, :db_save
		def db_save(options={})
			ensure_hash_has_symbol(self, :_id)
			ensure_hash_has_symbol(self, :type) # should be the id of the workflowtype that generated this workflow
			original_db_save(options)
		end
	end

	class WorkflowItems < Workflows::WorkflowBase
		# TODO - integrate status mixin
		#include WorkflowsStatus

	end
end