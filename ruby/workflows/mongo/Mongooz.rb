require 'mongo'
include Mongo

module Mongooz
	module Base
		DEFAULT_HOST="localhost"
		DEFAULT_PORT="27017"
		DEFAULT_DB="mongooz_test"

		def self.client(options = {}, &block)
			host=options[:host] || DEFAULT_HOST
			port=options[:port] || DEFAULT_PORT

			client=MongoClient.new(host,port)

			return client unless block
			begin
				block.call(client)
			ensure
				client.close
			end
		end
		def self.db(options = {}, &block)
			db_host=options[:host] || DEFAULT_HOST
			db_port=options[:port] || DEFAULT_PORT
			db_name=options[:db] || DEFAULT_DB

			client=Mongooz::Base::client({:host => db_host, :port => db_port})
			return client[db_name] unless block
			begin
				block.call(client[db_name])
			ensure
				client.close
			end
		end
		def self.collection(options={}, &block)
			db_host=options[:host] || DEFAULT_HOST
			db_port=options[:port] || DEFAULT_PORT
			db_name=options[:db] || DEFAULT_DB
			collection_name=options[:collection]
			raise "Missing required :collection parameter" unless collection_name

			db=Mongooz::Base::db(:host => db_host, :port => db_port, :db => db_name)
			return db[collection_name] unless block
			begin
				block.call(db[collection_name])
			ensure
				db.connection.close
			end
		end
	end# Base

	# 'extend' this to attach it to your eigenclass
	module Getters

		# override this in your class to provide default options
		# to the various mongooz APIs, such as a default
		# collection name, etc
		def get_defaults
			nil
		end

		def get_with_bson(options={})
			id=options[:_id]
			raise "Missing required :_id options parameter" unless id

			defaults=get_defaults
			if defaults
				options[:collection]=defaults[:collection] unless options[:collection]
				options[:db]=defaults[:db] unless options[:db]
				options[:host]=defaults[:host] unless options[:host]
				options[:port]=defaults[:port] unless options[:port]
			end

			result=nil
			Mongooz::Base.collection(options) do |col|
				result=col.find_one(:_id => id)
			end

			result
		end
	end
end
