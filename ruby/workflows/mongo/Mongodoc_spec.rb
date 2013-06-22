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

	describe "crud operations" do
		before :all do
			Mongodoc.configure(:db => 'mongodoc_test_db')
			@col_name='test'

			@col=Mongodoc.collection(:collection => @col_name)
			250.times{ |i| @col.insert( {:name=>"foo#{i}", :value=>i} ) }
		end
		after :all do
			@col.db.connection.drop_database(@col.db.name)
		end
		describe "::get_paged" do
			before :all do
				@page_size=10
				@page=0
			end
			describe "fail cases" do
				it "fails with negative page" do
					expect{Mongodoc.get_paged(:page_size=>@page_size, :page=>-1, :collection=>@col_name)}.to raise_error
				end
				it "fails with negative page size" do
					expect{Mongodoc.get_paged(:page_size=>-1, :page=>@page, :collection=>@col_name)}.to raise_error
				end
				it "returns a non-nil, empty list on a nonexisting collection" do
					list=Mongodoc.get_paged(:page=>@page, :page_size=>@page_size, :collection=>'bla')
					expect(list).to_not be_nil
					expect(list.count).to eq(0)
				end
			end
			describe "pass cases" do
				context "on an existing collection with items in it" do
					it "returns a non empty list" do
						list=Mongodoc.get_paged(:page=>@page, :page_size=>@page_size, :collection=>@col_name)
						expect(list).to_not be_nil
						expect(list).to be_a_kind_of(Enumerable)
						expect(list).to be_an_instance_of(Array)
						expect(list.count).to be > 0
					end
					it "pages correctly" do
						page_one=Mongodoc.get_paged(:page=>0, :page_size=>@page_size, :collection=>@col_name)
						page_two=Mongodoc.get_paged(:page=>1, :page_size=>(@page_size-1), :collection=>@col_name)
						expect(page_one.last).to eq(page_two.first)
					end
				end
			end
		end# get_paged
		describe "get by id string" do
			before :all do
				@raw_item=@col.find.next
				@id_str=@raw_item['_id'].to_s
			end
			it "throws an error with anything that's not a valid bson string" do
				expect{Mongodoc.get_with_id_string(:collection=>@col_name, :_id=>nil)}.to raise_error
				expect{Mongodoc.get_with_id_string(:collection=>@col_name, :_id=>'hi')}.to raise_error
				expect{Mongodoc.get_with_id_string(:collection=>@col_name, :_id=>[])}.to raise_error
			end
			it "returns a raw hash back with a valid bson string that exists" do
				raw_hash=Mongodoc.get_with_id_string(:collection=>@col_name, :_id=>@id_str)
				expect(raw_hash).to eql(@raw_item)
			end
			it "returns nil for a valid bson string that doesn't exist" do
				raw_hash=Mongodoc.get_with_id_string(:collection=>@col_name, :_id=>@id_str.reverse)
				expect(raw_hash).to be_nil
			end
			it "returns nil for an invalid collection name" do
				raw_hash=Mongodoc.get_with_id_string(:collection=>'mumble', :_id=>@id_str)
				expect(raw_hash).to be_nil
			end
		end
		describe "get by bson id object" do
			before :all do
				@raw_item=@col.find.next
				@bson=@raw_item['_id']
			end
			it "throws an error with nil id" do
				expect{Mongodoc.get_with_bson(:collection=>@col_name, :_id=>nil)}.to raise_error
			end
			it "does not throw an error with random, non-nil objects" do
				expect{Mongodoc.get_with_bson(:collection=>@col_name, :_id=>'hi')}.to_not raise_error
				expect{Mongodoc.get_with_bson(:collection=>@col_name, :_id=>[])}.to_not raise_error
			end
			it "returns a raw hash back with a valid bson object that exists" do
				raw_hash=Mongodoc.get_with_bson(:collection=>@col_name, :_id=>@bson)
				expect(raw_hash).to eql(@raw_item)
			end
			it "returns nil for a valid bson that doesn't exist" do
				bson=BSON.ObjectId(@bson.to_s.reverse)
				raw_hash=Mongodoc.get_with_bson(:collection=>@col_name, :_id=>bson)
				expect(raw_hash).to be_nil
			end
			it "returns nil for an invalid collection name" do
				raw_hash=Mongodoc.get_with_bson(:collection=>'mumble', :_id=>@bson)
				expect(raw_hash).to be_nil
			end
		end
		describe "insert" do
			it "throws an exception if you insert nil" do
				expect{Mongodoc.insert(nil, :collection=>@col_name)}.to raise_error
			end
			it "throws an exception with no args" do
				expect{Mongodoc.insert}.to raise_error
			end
			it "returns a bson object when you insert something non-nil" do
				expect(Mongodoc.insert({:name=>'inserted', :value=>987987}, :collection=>@col_name)).to be_an_instance_of(BSON::ObjectId)
			end
		end
		describe "update" do
			it "throws exception if called with less than 2 args" do
				expect{Mongodoc.update}.to raise_error
				expect{Mongodoc.update('adf')}.to raise_error
			end
			it "throws exception if second arg is not a hash" do
				expect{Mongodoc.update('adsf',nil)}.to raise_error
				expect{Mongodoc.update('asdf',[])}.to raise_error
				expect{Mongodoc.update('asdf','will barf')}.to raise_error
			end
			it "returns a hash with an 'n' key which is a Fixnum if args are valid" do
				err_hash=Mongodoc.update('junk string',{}, :collection=>@col_name)
				expect(err_hash).to be_a_kind_of(Hash) # it's actually an instance of BSON::OrderedHash
				expect(err_hash['n']).to be_an_instance_of(Fixnum)
			end
			it "returns a hash with n=0 for valid, nonexisting args" do
				err_hash=Mongodoc.update('junk string',{}, :collection=>@col_name)
				expect(err_hash['n']).to eq(0)
			end
			describe "for existing item" do
				before :all do
					@raw_item=@col.find.next
					@bson=@raw_item['_id']
				end
				it "returns a hash with n=1 for valid, existing args" do
					err_hash=Mongodoc.update(@bson, @raw_item, :collection=>@col_name)
					expect(err_hash['n']).to eq(1)
				end
				it "actually updates what's in the db for valid, existing args" do
					@raw_item[:foo=>'bar']
					err_hash=Mongodoc.update(@bson, @raw_item, :collection=>@col_name)
					@updated=Mongodoc.get_with_bson(:_id=>@bson, :collection=>@col_name)
					expect(@updated).to eql(@raw_item)
				end
			end
		end
	end# crud operations
end