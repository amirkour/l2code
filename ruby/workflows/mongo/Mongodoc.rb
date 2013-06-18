require 'mongo'
include Mongo

class Mongodoc
	@DEFAULT_HOST='localhost'
	@DEFAULT_PORT=27017
	class << self
		attr_reader :DEFAULT_PORT, :DEFAULT_HOST
	end

	def client(options = {}, &block)
		host=options[:host] || Mongodoc.DEFAULT_HOST
		port=options[:port] || Mongodoc.DEFAULT_PORT

		client=MongoClient.new(host,port)

		return client unless block
		begin
			block.call(client)
		ensure
			client.close
		end
	end
end