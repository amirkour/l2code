require './Mongooz.rb'

class PersistTest
	include Mongooz::Persist
end

describe Mongooz do
	describe "::Persist" do
		before :all do
			@test_collection='mongooz_persist_spec_test_collection'
			@id=nil
			@raw_item={:foo=>'bar',:baz=>'baz'}
			@pt=PersistTest.new
			Mongooz::Base.collection(:collection=>@test_collection) do |col|
				@id=col.insert(@raw_item)
				@raw_item[:_id] = @id
				200.times{|i| col.insert({:name=>"Foo#{i}", :value=>i})}
			end
		end
		after :all do
			Mongooz::Base.db{ |db| db.drop_collection(@test_collection) }
		end
		describe "when included in a class" do
			it "defines an mongooz_update function on an instance of your class" do
				expect(@pt.methods.include?(:mongooz_update)).to be_true
			end
			it "defines an mongooz_insert function on an instance of your class" do
				expect(@pt.methods.include?(:mongooz_insert)).to be_true
			end
			it "doesn't define mongooz_insert or mongooz_update on the class itself" do
				expect(PersistTest.methods.include?(:mongooz_update)).to_not be_true
				expect(PersistTest.methods.include?(:mongooz_insert)).to_not be_true
			end
		end
		describe ".mongooz_insert" do
			it "throws an exception if you mongooz_insert nil" do
				expect{@pt.mongooz_insert(nil, :collection=>@test_collection)}.to raise_error
			end
			it "throws an exception with no args" do
				expect{@pt.mongooz_insert}.to raise_error
			end
			it "returns a bson object when you mongooz_insert something non-nil" do
				expect(@pt.mongooz_insert({:name=>'inserted', :value=>987987}, :collection=>@test_collection)).to be_an_instance_of(BSON::ObjectId)
			end
		end# .mongooz_insert
		describe ".mongooz_update" do
			it "throws exception if called with less than 2 args" do
				expect{@pt.mongooz_update}.to raise_error
				expect{@pt.mongooz_update('adf')}.to raise_error
			end
			it "throws exception if second arg is not a hash" do
				expect{@pt.mongooz_update('adsf',nil)}.to raise_error
				expect{@pt.mongooz_update('asdf',[])}.to raise_error
				expect{@pt.mongooz_update('asdf','will barf')}.to raise_error
			end
			it "returns a hash with an 'n' key which is a Fixnum if args are valid" do
				err_hash=@pt.mongooz_update('junk string',{}, :collection=>@test_collection)
				expect(err_hash).to be_a_kind_of(Hash) # it's actually an instance of BSON::OrderedHash
				expect(err_hash['n']).to be_an_instance_of(Fixnum)
			end
			it "returns a hash with n=0 for valid, nonexisting args" do
				err_hash=@pt.mongooz_update('junk string',{}, :collection=>@test_collection)
				expect(err_hash['n']).to eq(0)
			end
			it "returns a hash with n=1 for valid, existing args" do
				err_hash=@pt.mongooz_update(@id, @raw_item, :collection=>@test_collection)
				expect(err_hash['n']).to eq(1)
			end
			it "actually updates what's in the db for valid, existing args" do
				old=@raw_item.clone
				@raw_item[:foo]='something else entirely'
				err_hash=@pt.mongooz_update(@id, @raw_item, :collection=>@test_collection)
				updated=Mongooz::Base.collection(:collection=>@test_collection).find(:_id=>@id).first
				expect(@raw_item[:foo]).to eql(updated['foo'])
				expect(@raw_item[:foo]).to_not eql(old[:foo])
				expect(updated['foo']).to_not eql(old[:foo])
				expect(updated['baz']).to eql(old[:baz])
				expect(updated['baz']).to eql(@raw_item[:baz])
			end
		end# .mongooz_update
	end# end ::Persist
end
