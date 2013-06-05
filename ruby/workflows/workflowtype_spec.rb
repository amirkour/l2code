
require './workflowtype.rb'

# how does 'context' fit into shit?
# what's a good website to go to for the various equality tests/methods

describe Workflowtype do

	describe "#new" do
		# could use this to run stuff before all tests in this 'describe' block:
		# before :all do
		# end

		context 'without any ctor attribs' do
			# or this to run stuff before each test one by one
			before :each do 
				@wt=Workflowtype.new
			end

			it 'gives you back a workflowtype object' do
				@wt.should be_an_instance_of(Workflowtype)
			end

			it 'has null attributes' do
				@wt.id.should be_nil
				@wt.name.should be_nil
			end
		end

		context 'with an id ctor attribute' do
			before :each do
				@wt=Workflowtype.new({:id => 5})
			end

			it 'has a non-nil id' do
				@wt.id.should_not be_nil
			end

			it 'has a nil name' do
				@wt.name.should be_nil
			end
		end

		context 'with a name ctor attribute' do
			before :each do
				@wt = Workflowtype.new({:name => "foo!"})
			end

			it 'has a non-nil name' do
				@wt.name.should_not be_nil
			end

			it 'has a nil id' do
				@wt.id.should be_nil
			end
		end

	end# end of #new

end