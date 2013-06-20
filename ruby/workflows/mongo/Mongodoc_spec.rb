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
			Mongodoc.configure({:host => default_host, :port => default_port, :db => default_db})
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
				before :all do
					@client=Mongodoc.client
				end
				after :all do
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
				before :all do
					@host="127.0.0.1"
					@port=27017
					@client=Mongodoc.client({:host => @host,:port => @port})
				end
				after :all do
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
				before :all do
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
	describe "::db_name_valid?" do
		it "returns false for 'test' db" do
			Mongodoc.db_name_valid?('test').should be_false
		end
		it "returns false for 'tests' db" do
			Mongodoc.db_name_valid?('tests').should be_false
		end
		it "returns false for a non-string arg" do
			Mongodoc.db_name_valid?(1).should be_false
		end
		it "returns true for anything non-nil that's not a test db" do
			Mongodoc.db_name_valid?('foo').should be_true
		end
		it "returns false for nil" do
			Mongodoc.db_name_valid?(nil).should be_false
		end
	end
	describe "::db" do
		context 'without having configured DB setting' do
			it "should raise an error" do
				expect { Mongodoc.db }.to raise_error
			end
		end
		context 'with configured DB setting, without DB arg' do
			before :all do
				@default_db=Mongodoc.DB
				@new_db='workflows'
				Mongodoc.configure({:db => @new_db})
			end
			after :all do
				Mongodoc.configure({:db => @default_db})
			end
			it 'should be an instance of Mongo::DB' do
				Mongodoc.db.should be_an_instance_of(Mongo::DB)
			end
			it "should be pointed at the #{@new_db} database" do
				Mongodoc.db.name.should == @new_db
			end
			it "should yield with a block" do
				expect {|b| Mongodoc.db({}, &b) }.to yield_with_args(Mongo::DB)
			end
		end
		context "with db arg" do
			it "should barf if the arg is 'test'" do
				expect { Mongodoc.db('test') }.to raise_error
			end
			it "should be an instance of Mongo::DB" do
				Mongodoc.db({:db => 'foo'}).should be_an_instance_of(Mongo::DB)
			end
			it "should be pointed at the 'foo' database" do
				Mongodoc.db({:db => 'foo'}).name.should == 'foo'
			end
			it "should yield with a block" do
				expect {|b| Mongodoc.db({:db => 'foo'}, &b) }.to yield_with_args(Mongo::DB)
			end
		end
	end
	describe "::collection" do
		before :all do
			@db_test='mongodoc_test_db'
			@collection_fake='foo_bar_baz'
			@collection_test='test_workflows'
			Mongodoc.configure({:db => @db_test})
			Mongodoc.db do |db|
				db[@collection_test].insert({:foo => 'bar'})
			end
		end
		after :all do
			Mongodoc.client do |client|
				client.drop_database(@db_test)
			end
		end
		it "raises an error without a collection name" do
			expect{Mongodoc.collection}.to raise_error
		end
		it "returns an object of type Mongo::Collection for fake collection #{@collection_fake}" do
			Mongodoc.collection(:collection => @collection_fake).should be_an_instance_of(Mongo::Collection)
		end
		it "returns an object of type Mongo::Collection for test collection #{@collection_test}" do
			Mongodoc.collection(:collection => @collection_test).should be_an_instance_of(Mongo::Collection)
		end
		it "returns a non-empty collection for test collection #{@collection_test}" do
			expect(Mongodoc.collection(:collection => @collection_test).count).to be > 0 
		end
		it "should yield with a block" do
			expect { |b| Mongodoc.collection(:collection => 'mumble', &b) }.to yield_with_args(Mongo::Collection)
		end
	end

	# describe "crud operations" do
	# 	before :all do
	# 		@db_test='mongodoc_test_db'
	# 		@collection_fake='foo_bar_baz'
	# 		@collection_test='test_workflows'

	# 		Mongodoc.configure({:db => @db_test})
	# 		Mongodoc.db do |db|
	# 			db[@collection_test].insert({:foo => 'bar'})
	# 		end
	# 	end
	# 	after :all do
	# 		Mongodoc.client do |client|
	# 			client.drop_database(@db_test)
	# 		end
	# 	end

	# 	describe "::get_paged" do
	# 		context "for non-existing collection" do
	# 			before :all do
	# 				Mongodoc.stub(:collection => @collection_fake)
	# 			end

	# 			it "gets nil" do
	# 				items=Mongodoc.get_paged
	# 				items.should be_nil
	# 			end
	# 		end

	# 		context "for existing collection" do
	# 			before :all do
	# 				Mongodoc.stub(:collection => @collection_test)
	# 			end
				
	# 			it "gets a page of items by default" do
	# 				items=Mongodoc.get_paged
	# 				items.should_not be_nil
	# 				items.empty?.should be_false
	# 			end
	# 		end
	# 	end
	# end
end