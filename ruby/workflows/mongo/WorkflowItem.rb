# serialize this
# {
# 	:status => 'bla',
# 	:step => 'bla',
# 	:type => 'import',
# 	:feedback => ['hi','bye','mums']
# }

# workflow items have to have a 'type' - the ID that will map it to it's
# workflow's steps
class WorkflowItem

	attr_accessor :parent_id 	# id of workflow parent
	attr_accessor :type 		# a string, should come from WorkflowType#name
	attr_accessor :step 		# the step accessor gets/sets step objects
	attr_accessor :status 		# status will just be a string
	attr_accessor :feedback 	# a list of strings

	def initialize(parent_id=nil, type=nil)
		raise "Cannot initialie a workflow item without a parent workflow id" unless parent_id
		raise "Cannot initialize a workflow item without a type (which should originate from a WorkflowType or Workflow.type" unless type
		@parent_id=parent_id
		@type=type

		# should probably load from module, something like
		#@module = WorkflowsModule.GetModuleForType(@type)
		#@step=@module.steps_hash.first or something
		#@status=@module.status_hash.ready or something
		@step=nil
		@status=nil
		@feedback=[]
		@raw_hash={}
		yield(@raw_hash) if block_given?
	end

	# error?
	# error #sets error
	# error! #immediately commits to db

	# processing?
	# processing
	# processing!

	# ready?
	# ready
	# ready!

	# complete?
	# complete
	# complete!


	# done? # ret true if on last step, false otherwise


	# save # should take a block, yield to it, then commit the item to db. without a block, simply commits.
	#      # if item doesn't have an id, does an insert and populates item's ID

	# step # return the step this item is on.
	# # you'll have to map json to a step object.
	# # if the steps are just a hash of symbols-to-steps, that's easy!

	# each_step # should take a block and pass successive steps to the block

	# to_s
end
