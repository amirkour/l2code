
require './workflowtype.rb'
# require_relative ..?

# the standard matchers are documented nicely on rspec's site, here:
# http://rubydoc.info/gems/rspec-expectations/frames
#
# run it like so:
# rspec workflowtype_spec.rb
#
# alternatively, with pretty output:
# rspec -f documentation workflowtype_spec.rb
# or, shorter:
# rspec -f d workflowtype_spec.rb
describe Workflowtype do

	describe "#new" do
		# could use this to run stuff before all tests in this 'describe' block:
		# before :all do
		# end

		context 'without any ctor attribs' do
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
				@wt=Workflowtype.new(:id => 5)
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
				@wt = Workflowtype.new(:name => "foo!")
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