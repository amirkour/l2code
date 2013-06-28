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
	end# Base
end
