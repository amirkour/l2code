require './Mongodoc.rb'

# workflow types just have an id and name and are factories
# for workflows of the same type.
# the 'name' of a workflowtype should bridge the gap between
# a workflow item associated to a given workflow type and the
# steps in that workflowtype.
#
# ex: the 'pricing' workflow items have steps a,b, and c, while
#     the 'import' workflow items have steps x, y, and z.
class WorkflowType < Mongodoc
	@COLLECTION='workflowtypes'
	attr_accessor :type  # every workflow type has this string (ie: "Pricing" workflow, "Import" workflow, etc)
end
