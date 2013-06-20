require 'mongo'
include Mongo

class Mongodoc

	# class var defaults, settable via Mongodoc.configure
	@HOST='localhost'
	@PORT=27017
	@DB='test'

	attr_accessor :raw_hash		# this is the raw hash going in and out of mongo

	#
	# class methods
	#
	class << self

		# set these via Mongodoc.configure
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
			db_host=options[:host] || Mongodoc.HOST
			db_port=options[:port] || Mongodoc.PORT
			db_name=options[:db] || Mongodoc.DB
			raise "No valid database specified - set the default to anything other than the 'test' db via Mongodoc::configure or pass the :db option to this function" unless db_name_valid?(db_name)

			client=Mongodoc.client({:host => db_host, :port => db_port})
			return client[db_name] unless block
			begin
				block.call(client[db_name])
			ensure
				client.close
			end
		end

		def collection(options={}, &block)
			db_host=options[:host] || Mongodoc.HOST
			db_port=options[:port] || Mongodoc.PORT
			db_name=options[:db] || Mongodoc.DB
			collection_name=options[:collection]
			raise "No valid collection specified" unless collection_name

			db=Mongodoc.db(:host => db_host, :port => db_port, :db => db_name)
			return db[collection_name] unless block
			begin
				block.call(db[collection_name])
			ensure
				db.connection.close
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


	end#end of class
end