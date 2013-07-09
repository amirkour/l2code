require './Mongooz.rb'

class PersistTest
	extend Mongooz::Persist
end

describe Mongooz do
	describe "::Persist" do
		before :all do
			@test_collection='mongooz_persist_spec_test_collection'
			@id=nil
			@raw_item={:foo=>'bar',:baz=>'baz'}
			Mongooz::Base.collection(:collection=>@test_collection) do |col|
				@id=col.insert(@raw_item)
				@raw_item[:_id] = @id
				200.times{|i| col.insert({:name=>"Foo#{i}", :value=>i})}
			end
		end
		after :all do
			Mongooz::Base.db{ |db| db.drop_collection(@test_collection) }
		end
		describe "when extended in a class" do
			it "defines an update function on your class" do
				expect(PersistTest.methods.include?(:update)).to be_true
			end
			it "defines an insert function on an instance of your object" do
				expect(PersistTest.methods.include?(:insert)).to be_true
			end
			it "doesn't define insert or update on the instances of itself" do
				pt=PersistTest.new
				expect(pt.methods.include?(:update)).to_not be_true
				expect(pt.methods.include?(:insert)).to_not be_true
			end
		end
		describe "insert" do
			it "throws an exception if you insert nil" do
				expect{PersistTest.insert(nil, :collection=>@test_collection)}.to raise_error
			end
			it "throws an exception with no args" do
				expect{PersistTest.insert}.to raise_error
			end
			it "returns a bson object when you insert something non-nil" do
				expect(PersistTest.insert({:name=>'inserted', :value=>987987}, :collection=>@test_collection)).to be_an_instance_of(BSON::ObjectId)
			end
		end
		describe "update" do
			it "throws exception if called with less than 2 args" do
				expect{PersistTest.update}.to raise_error
				expect{PersistTest.update('adf')}.to raise_error
			end
			it "throws exception if second arg is not a hash" do
				expect{PersistTest.update('adsf',nil)}.to raise_error
				expect{PersistTest.update('asdf',[])}.to raise_error
				expect{PersistTest.update('asdf','will barf')}.to raise_error
			end
			it "returns a hash with an 'n' key which is a Fixnum if args are valid" do
				err_hash=PersistTest.update('junk string',{}, :collection=>@test_collection)
				expect(err_hash).to be_a_kind_of(Hash) # it's actually an instance of BSON::OrderedHash
				expect(err_hash['n']).to be_an_instance_of(Fixnum)
			end
			it "returns a hash with n=0 for valid, nonexisting args" do
				err_hash=PersistTest.update('junk string',{}, :collection=>@test_collection)
				expect(err_hash['n']).to eq(0)
			end
			it "returns a hash with n=1 for valid, existing args" do
				err_hash=PersistTest.update(@id, @raw_item, :collection=>@test_collection)
				expect(err_hash['n']).to eq(1)
			end
			it "actually updates what's in the db for valid, existing args" do
				old=@raw_item.clone
				@raw_item[:foo]='something else entirely'
				err_hash=PersistTest.update(@id, @raw_item, :collection=>@test_collection)
				updated=Mongooz::Base.collection(:collection=>@test_collection).find(:_id=>@id).first
				expect(@raw_item[:foo]).to eql(updated['foo'])
				expect(@raw_item[:foo]).to_not eql(old[:foo])
				expect(updated['foo']).to_not eql(old[:foo])
				expect(updated['baz']).to eql(old[:baz])
				expect(updated['baz']).to eql(@raw_item[:baz])
			end
		end
	end
end
