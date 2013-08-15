module Workflows

	class WorkflowTypes < Workflows::WorkflowBase

		alias_method :original_db_insert, :db_insert
		def db_insert(options={})
			ensure_hash_has_symbol(self, :_id)
			original_db_insert(options)
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
			raise "Could not save new workflow to db" unless wf.db_insert
			wf
		end

		def each_step(name_of_first_step=nil, &block)
			raise "Cannot get steps for a workflow type w/ no _id" unless self[:_id]
			
			steps=Workflows::Steps.get_steps(self[:_id])
			raise "No steps available for workflow #{self[:_id]}" unless steps && steps.count > 0

			if name_of_first_step
				while steps.count > 0 && steps[0].name!=name_of_first_step
					steps.shift
				end

				if steps.count <= 0 || steps[0].name!=name_of_first_step
					raise "Workflow #{self[:_id]} did not have a step with name #{name_of_first_step}"
				end
			end

			return steps unless block
			steps.each do |next_step|
				block.call(next_step)
			end
		end
	end

	class Workflowz < Workflows::WorkflowBase
		alias_method :original_db_insert, :db_insert
		def db_insert(options={})
			ensure_hash_has_symbol(self, :_id)
			ensure_hash_has_symbol(self, :type) # should be the id of the workflowtype that generated this workflow
			original_db_insert(options)
		end
	end

	class WorkflowItems < Workflows::WorkflowBase
		# TODO - integrate status mixin
		#include WorkflowsStatus

	end
end
