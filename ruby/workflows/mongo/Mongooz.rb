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
		# to the various mongooz APIs. IE:
		# {:collection=>'some default collection name', :db=>'some default db', :host=>'localhost', :port=>27017}
		def get_defaults
			nil
		end

		# will override options in the given hash with defaults, where defaults
		# are specified
		def set_options(options)
			return unless options.kind_of?(Hash)
			defaults=get_defaults
			if defaults
				options[:collection]=options[:collection] || defaults[:collection]
				options[:db]=options[:db] || defaults[:db]
				options[:host]=options[:host] || defaults[:host]
				options[:port]=options[:port] || defaults[:port]
			end
		end

		def get_with_bson(options={})
			id=options[:_id]
			raise "Missing required :_id options parameter" unless id

			set_options(options)
			result=nil
			Mongooz::Base.collection(options) do |col|
				result=col.find_one(:_id => id)
			end

			result
		end

		def get_with_string(options={})
			id=options[:_id]
			raise "Missing required :_id options parameter" unless id

			set_options(options)
			result=nil
			Mongooz::Base.collection(options) do |col|
				result=col.find_one(:_id => BSON.ObjectId(id))
			end

			result
		end
	end
end
