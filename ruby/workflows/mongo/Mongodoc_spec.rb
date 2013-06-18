require 'mongo'
require './Mongodoc.rb'
require 'json'
include Mongo
# require_relative ..?

# the standard matchers are documented nicely on rspec's site, here:
# http://rubydoc.info/gems/rspec-expectations/frames
#
# run it like so:
# rspec Mongodoc.rb
#
# alternatively, with pretty output:
# rspec -f documentation Mongodoc.rb
# or, shorter:
# rspec -f d Mongodoc.rb
describe Mongodoc do

	describe '#new' do
		before :each do 
			@doc=Mongodoc.new
		end
		it 'creates an object that is_a Mongodoc' do
			@doc.should be_an_instance_of(Mongodoc)
		end
	end

	describe '#client' do
		describe 'without configuration options' do
			context 'without a block' do
				before :each do
					@wt=Mongodoc.new
					@client=@wt.client
				end
				after :each do
					@client.close
				end

				it 'returns a connection' do
					@client.should_not be_nil
					@client.should be_connected
				end

				it "returns a connection talking to host #{Mongodoc.DEFAULT_HOST}" do
					@client.host.should == "#{Mongodoc.DEFAULT_HOST}"
				end

				it "returns a connection talking on port #{Mongodoc.DEFAULT_PORT}" do
					@client.port.should == Mongodoc.DEFAULT_PORT
				end
			end

			context 'with a block' do
				before :each do
					@wt=Mongodoc.new
				end

				it 'should yield' do

					# block should yield, passing an argument of type Mongo::MongoClient into the block
					expect {|b| @wt.client(&b) }.to yield_with_args(MongoClient)
				end
			end
		end
		describe 'with configuration options' do
			context 'without a block' do
				before :each do
					@wt=Mongodoc.new
					@host="127.0.0.1"
					@port=27017
					@client=@wt.client({:host => @host,:port => @port})
				end
				after :each do
					@client.close
				end

				it 'returns a connection' do
					@client.should_not be_nil
					@client.should be_connected
				end

				it "returns a connection talking to host #{@host}" do
					@client.host.should == "#{@host}"
				end

				it "returns a connection talking on port #{@port}" do
					@client.port.should == @port
				end
			end

			context 'with a block' do
				before :each do
					@wt=Mongodoc.new
					@host="127.0.0.1"
					@port=27017
				end

				it 'should yield' do

					# block should yield, passing an argument of type Mongo::MongoClient into the block
					expect {|b| @wt.client({:host => @host,:port => @port}, &b) }.to yield_with_args(MongoClient)
				end
			end
		end
	end# #client
end