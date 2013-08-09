# todo
# i'm totally busted right now, please fix me
# (i was moved from the workflows folder and stuffed into the 'specs' subfolder of the mongooz gem
# w/o being cleaned)
require './Mongooz.rb'
require 'mongo'
include Mongo

describe Mongooz do
	describe '::Base' do
		describe '::client' do
			describe 'without configuration options' do
				context 'without a block' do
					before :all do
						@client=Mongooz::Base::client
					end
					after :all do
						@client.close
					end

					it 'returns a connection' do
						expect(@client).to_not be_nil
						expect(@client).to be_connected
					end

					it "returns a connection talking to host #{Mongooz::Base::DEFAULT_HOST}" do
						expect(@client.host).to eq(Mongooz::Base::DEFAULT_HOST)
					end

					it "returns a connection talking on port #{Mongooz::Base::DEFAULT_PORT}" do
						expect(@client.port).to eq(Mongooz::Base::DEFAULT_PORT)
					end
				end

				context 'with a block' do
					it 'should yield' do

						# block should yield, passing an argument of type Mongo::MongoClient into the block
						expect {|b| Mongooz::Base::client(&b) }.to yield_with_args(MongoClient)
					end
				end
			end
			describe 'with configuration options' do
				before :all do
					@host="127.0.0.1"
					@port=27017
					@client=Mongooz::Base::client({:host => @host,:port => @port})
				end
				after :all do
					@client.close
				end
				context 'without a block' do
					it 'returns a connection' do
						expect(@client).to_not be_nil
						expect(@client).to be_connected
					end
					it "returns a connection talking to host #{@host}" do
						expect(@client.host).to eq(@host)
					end

					it "returns a connection talking on port #{@port}" do
						expect(@client.port).to  eq(@port)
					end
				end
				context 'with a block' do
					it 'should yield' do

						# block should yield, passing an argument of type Mongo::MongoClient into the block
						expect {|b| Mongooz::Base::client({:host => @host,:port => @port}, &b) }.to yield_with_args(MongoClient)
					end
				end
			end
		end# ::client
		describe "::db" do
			context 'without any args' do
				before :all do
					@db=Mongooz::Base::db
				end
				after :all do
					@db.connection.close
				end
				it 'should be an instance of Mongo::DB' do
					expect(@db).to be_an_instance_of(Mongo::DB)
				end
				it "should be pointed at the #{Mongooz::Base::DEFAULT_DB} database" do
					expect(@db.name).to eq(Mongooz::Base::DEFAULT_DB)
				end
				it "should yield with a block" do
					expect {|b| Mongooz::Base::db(&b) }.to yield_with_args(Mongo::DB)
				end
			end
			context "with db arg" do
				before :all do
					@db_name='foo'
					@db=Mongooz::Base::db(:db => @db_name)
				end
				it "should be an instance of Mongo::DB" do
					expect(@db).to be_an_instance_of(Mongo::DB)
				end
				it "should be pointed at the '#{@db_name}' database" do
					expect(@db.name).to eq(@db_name)
				end
				it "should yield with a block" do
					expect {|b| Mongooz::Base::db(:db => @db_name, &b) }.to yield_with_args(Mongo::DB)
				end
			end
		end# end ::db
		describe "::collection" do
			before :all do
				@collection_fake='nonexisting'
				@collection_test='mongooz_test_collection_spec_collection'
				Mongooz::Base::db do |db|
					db[@collection_test].insert({:foo=>'bar'})
				end
			end
			after :all do
				Mongooz::Base::db do |db|
					db.drop_collection(@collection_test)
				end
			end
			it "raises an error without a collection name" do
				expect{Mongooz::Base::collection}.to raise_error
			end
			it "returns an object of type Mongo::Collection for fake collection #{@collection_fake}" do
				expect(Mongooz::Base::collection(:collection => @collection_fake)).to be_an_instance_of(Mongo::Collection)
			end
			it "returns an object of type Mongo::Collection for test collection #{@collection_test}" do
				expect(Mongooz::Base::collection(:collection => @collection_test)).to be_an_instance_of(Mongo::Collection)
			end
			it "returns a non-empty collection for test collection #{@collection_test}" do
				expect(Mongooz::Base::collection(:collection => @collection_test).count).to be > 0 
			end
			it "should yield with a block" do
				expect{|b| Mongooz::Base::collection(:collection => 'mumble', &b) }.to yield_with_args(Mongo::Collection)
			end
		end
	end# end ::Base
end# end Mongooz