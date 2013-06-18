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
	end
end