require 'mongo'
include Mongo

class Mongodoc
	@HOST='localhost'
	@PORT=27017
	@DB='test'
	class << self
		attr_reader :PORT, :HOST, :DB

		def configure(options = {})
			@HOST = options[:host] || @HOST
			@PORT = options[:port] || @PORT
			@DB = options[:db] || @DB
		end

		def client(options = {}, &block)
			host=options[:host] || Mongodoc.HOST
			port=options[:port] || Mongodoc.PORT

			client=MongoClient.new(host,port)

			return client unless block
			begin
				block.call(client)
			ensure
				client.close
			end
		end

		def db(options = {}, &block)
			db_name=options[:db] || Mongodoc.DB
			raise "No valid database specified - set the default to anything other than the 'test' db via Mongodoc::configure or pass the :db option to this function" unless db_name_valid?(db_name)

			client=Mongodoc.client
			return client[db_name] unless block
			begin
				block.call(client[db_name])
			ensure
				client.close
			end
		end

		def db_name_valid?(name=nil)
			return false if name.nil?
			return false if name.length <= 0
			return false if name == 'test' || name == 'tests'
			true
		rescue
			false
		end
	end
end