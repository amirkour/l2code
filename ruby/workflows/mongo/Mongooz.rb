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

		def get_paged(options={})

			max_page=100		# bugbug - configurable?
			max_page_size=25    # bugbug - configurable?
			page=options[:page] || 0
			raise "Page number must be a positive number not exceeding #{max_page}" unless page >= 0 && page < max_page

			page_size=options[:page_size] || max_page_size # bugbug - configurable?
			raise "Page size must be a positive number not exceeding #{max_page_size}" unless(page_size <= max_page_size && page_size > 0)

			num_to_skip=page * page_size
			set_options(options)

			#BUGBUG - this list should return the actual subclass type, or maybe a generic subclass (which all concretes
			#descend from) which will handle the casting/converting for you ...
			results=[]
			Mongooz::Base.collection(options) do |col|

				# this is probably how best to do paging but it requires you keep track of
				# an anchor element, and a minimum anchor value, and the last element of the
				# previous page
				# col.find({:value=>{:$gte=>30}}, {:limit=>20,:sort=>{:value=>:asc}}).each{|x| puts x}
				cursor=col.find( {}, {:limit => page_size, :skip=>num_to_skip})
				cursor.each{|x| results << x}
			end

			results
		end
	end
end
