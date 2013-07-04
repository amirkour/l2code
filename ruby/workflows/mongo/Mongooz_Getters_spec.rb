require './Mongooz.rb'

class GetTest
	extend Mongooz::Getters
end

describe Mongooz do
	describe '::Getters' do
		before :all do
			@test_collection='mongooz_getters_spec_test_db'
			@id=nil
			Mongooz::Base.collection(:collection=>@test_collection) do |col|
				@id=col.insert({:foo=>'bar',:baz=>'baz'})
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
		end
	end# ::Getters
end
