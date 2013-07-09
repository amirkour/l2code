require './Mongooz.rb'

class GetTest
	extend Mongooz::Getters
end

describe Mongooz do
	describe '::Getters' do
		before :all do
			@test_collection='mongooz_getters_spec_test_collection'
			@id=nil
			Mongooz::Base.collection(:collection=>@test_collection) do |col|
				@id=col.insert({:foo=>'bar',:baz=>'baz'})
				200.times{|i| col.insert({:name=>"Foo#{i}", :value=>i})}
			end
		end
		after :all do
			Mongooz::Base.db{ |db| db.drop_collection(@test_collection) }
		end

		describe "::get_with_bson" do
			it "barfs without an _id option" do
				expect{GetTest.get_with_bson}.to raise_error
			end
			it "retrieves nil for a non-existing, valid BSON doc" do
				b=BSON.ObjectId(@id.to_s.reverse)
				expect(GetTest.get_with_bson(:_id=>b, :collection=>@test_collection)).to be_nil
			end
			it "retrieves a hash for an existing bson doc" do
				expect(GetTest.get_with_bson(:_id=>@id, :collection=>@test_collection)).to_not be_nil
				expect(GetTest.get_with_bson(:_id=>@id, :collection=>@test_collection)).to be_a_kind_of(Hash)
			end
			describe "with get_defaults defined" do
				before :all do
					class GetTest
						class << self
							def get_defaults
								{:collection=>'mongooz_getters_spec_test_db'}#for some reason, get access @test_collection here ...
							end
						end
					end
				end
				after :all do
					class GetTest
						class << self
							remove_method :get_defaults
						end
					end
				end
				it "has a get_defaults function that returns a hash with a :collection in it" do
					hash=GetTest.get_defaults
					expect(hash).to_not be_nil
					expect(hash).to be_an_instance_of(Hash)
				end
				it "doesn't need to be called w/ a :collection option" do
					expect(GetTest.get_with_bson(:_id=>@id)).to_not be_nil
				end
			end
		end# ::get_with_bson

		describe "::get_with_string" do
			before :all do
				@id_str=@id.to_s
			end
			it "throws an error with anything that's not a valid bson string" do
				expect{GetTest.get_with_string(:collection=>@test_collection, :_id=>nil)}.to raise_error
				expect{GetTest.get_with_string(:collection=>@test_collection, :_id=>'hi')}.to raise_error
				expect{GetTest.get_with_string(:collection=>@test_collection, :_id=>[])}.to raise_error
			end
			it "returns a raw hash back with a valid bson string that exists" do
				raw_hash=GetTest.get_with_string(:collection=>@test_collection, :_id=>@id_str)
				expect(raw_hash).to_not be_nil
				expect(raw_hash).to be_a_kind_of(Hash)
			end
			it "returns nil for a valid bson string that doesn't exist" do
				raw_hash=GetTest.get_with_string(:collection=>@test_collection, :_id=>@id_str.reverse)
				expect(raw_hash).to be_nil
			end
			it "returns nil for an invalid collection name" do
				raw_hash=GetTest.get_with_string(:collection=>'mumble', :_id=>@id_str)
				expect(raw_hash).to be_nil
			end
		end# ::get_with_string

		describe "::get_paged" do
			before :all do
				@page_size=10
				@page=0
			end
			describe "fail cases" do
				it "fails with negative page" do
					expect{GetTest.get_paged(:page_size=>@page_size, :page=>-1, :collection=>@test_collection)}.to raise_error
				end
				it "fails with negative page size" do
					expect{GetTest.get_paged(:page_size=>-1, :page=>@page, :collection=>@test_collection)}.to raise_error
				end
				it "returns a non-nil, empty list on a nonexisting collection" do
					list=GetTest.get_paged(:page=>@page, :page_size=>@page_size, :collection=>'bla')
					expect(list).to_not be_nil
					expect(list.count).to eq(0)
				end
			end
			describe "pass cases" do
				context "on an existing collection with items in it" do
					it "returns a non empty list" do
						list=GetTest.get_paged(:page=>@page, :page_size=>@page_size, :collection=>@test_collection)
						expect(list).to_not be_nil
						expect(list).to be_a_kind_of(Enumerable)
						expect(list).to be_an_instance_of(Array)
						expect(list.count).to be > 0
					end
					it "pages correctly" do
						page_one=GetTest.get_paged(:page=>0, :page_size=>@page_size, :collection=>@test_collection)
						page_two=GetTest.get_paged(:page=>1, :page_size=>(@page_size-1), :collection=>@test_collection)
						expect(page_one.last).to eq(page_two.first)
					end
				end
			end
		end# ::get_paged
	end# ::Getters
end
