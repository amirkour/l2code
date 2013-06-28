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
		end# #client
	end# end ::Base
end# end Mongooz