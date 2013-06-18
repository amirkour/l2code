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
	describe '::configure' do
		it 'sets the host and port and db' do
			default_host=Mongodoc.HOST
			default_port=Mongodoc.PORT
			default_db=Mongodoc.DB

			host='foo'
			port=1234
			db='nonexistent'
			Mongodoc.configure({:host => host, :port => port, :db => db})
			Mongodoc.HOST.should == host
			Mongodoc.PORT.should == port
			Mongodoc.DB.should == db

			# set back to defaults - remainder of specs in this file depend on default host/port/db
			Mongodoc.configure({:host => default_host, :port => default_port, :db => db})
		end
	end

	describe '::HOST' do
		it 'cannot be assigned to' do
			expect { Mongodoc.HOST='hi there'}.to raise_error
		end
	end

	describe '::PORT' do
		it 'cannot be assigned to' do
			expect { Mongodoc.PORT=1}.to raise_error
		end
	end

	describe '::DB' do
		it 'cannot be assigned to' do
			expect { Mongodoc.DB='hi'}.to raise_error
		end
	end

	# describe '#new' do
	# 	before :each do 
	# 		@doc=Mongodoc.new
	# 	end
	# 	it 'creates an object that is_a Mongodoc' do
	# 		@doc.should be_an_instance_of(Mongodoc)
	# 	end
	# end

	describe '::client' do
		describe 'without configuration options' do
			context 'without a block' do
				before :each do
					@client=Mongodoc.client
				end
				after :each do
					@client.close
				end

				it 'returns a connection' do
					@client.should_not be_nil
					@client.should be_connected
				end

				it "returns a connection talking to host #{Mongodoc.HOST}" do
					@client.host.should == "#{Mongodoc.HOST}"
				end

				it "returns a connection talking on port #{Mongodoc.PORT}" do
					@client.port.should == Mongodoc.PORT
				end
			end

			context 'with a block' do

				it 'should yield' do

					# block should yield, passing an argument of type Mongo::MongoClient into the block
					expect {|b| Mongodoc.client(&b) }.to yield_with_args(MongoClient)
				end
			end
		end
		describe 'with configuration options' do
			context 'without a block' do
				before :each do
					@host="127.0.0.1"
					@port=27017
					@client=Mongodoc.client({:host => @host,:port => @port})
				end
				after :each do
					@client.close
				end

				it 'returns a connection' do
					@client.should_not be_nil
					@client.should be_connected
				end

				it "returns a connection talking to host #{@host}" do
					@client.host.should == @host
				end

				it "returns a connection talking on port #{@port}" do
					@client.port.should == @port
				end
			end

			context 'with a block' do
				before :each do
					@host="127.0.0.1"
					@port=27017
				end

				it 'should yield' do

					# block should yield, passing an argument of type Mongo::MongoClient into the block
					expect {|b| Mongodoc.client({:host => @host,:port => @port}, &b) }.to yield_with_args(MongoClient)
				end
			end
		end
	end# #client
end