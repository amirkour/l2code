require './Mongooz.rb'


module Workflows

	@DEFAULT_DB='workflows'
	@DEFAULT_HOST='localhost'
	@DEFAULT_PORT=27017
	class << self
		attr_reader :DEFAULT_DB, :DEFAULT_HOST, :DEFAULT_PORT	
		def defaults(options={})
			@DEFAULT_DB=options[:db] if options[:db]
			@DEFAULT_HOST=options[:host] if options[:host]
			@DEFAULT_PORT=options[:port] if options[:port]
		end
	end

	# class that all workflow related objects derive from
	class WorkflowHash < Hash

		class << self
			def get_class_name_without_namespace(class_to_retrieve_name_from)
				return nil unless class_to_retrieve_name_from.respond_to?(:name)
				class_to_retrieve_name_from.name.split("::").last.downcase
			end

			# will override options in the given hash with defaults, where defaults
			# are specified
			def set_db_options(options)
				options[:collection]=options[:collection] || WorkflowHash.get_class_name_without_namespace(self)
				options[:db]=options[:db] || Workflows.DEFAULT_DB
				options[:host]=options[:host] || Workflows.DEFAULT_HOST
				options[:port]=options[:port] || Workflows.DEFAULT_PORT
			end

			def typified_result_hash_or_nil(hash_to_wrap)
				return nil unless hash_to_wrap.kind_of?(Hash)
				self.new.update(hash_to_wrap)
			end

			def db_get_with_bson(options={})
				id=options[:_id]
				raise "Missing required :_id options parameter" unless id

				set_db_options(options)
				result=nil
				Mongooz::Base.collection(options) do |col|
					result=col.find_one(:_id => id)
				end

				typified_result_hash_or_nil(result)
			end

			def db_get_with_string(options={})
				id=options[:_id]
				raise "Missing required :_id options parameter" unless id

				set_db_options(options)
				result=nil
				Mongooz::Base.collection(options) do |col|
					result=col.find_one(:_id => BSON.ObjectId(id))
				end

				typified_result_hash_or_nil(result)
			end
		end

		def set_db_options(options)
			options[:collection]=options[:collection] || WorkflowHash.get_class_name_without_namespace(self.class)
			options[:db]=options[:db] || Workflows.DEFAULT_DB
			options[:host]=options[:host] || Workflows.DEFAULT_HOST
			options[:port]=options[:port] || Workflows.DEFAULT_PORT
		end

		def db_insert(raw_hash, options={})
			set_db_options(options)
			id=nil
			Mongooz::Base.collection(options) do |col|
				id=col.insert(raw_hash)
			end

			id
		end

		# probably not very useful - most of your update APIs should be targeted for performance.
		# this one will "replace" the given bson_id with the given raw_hash
		def db_update(bson_id, raw_hash, options={})
			set_db_options(options)
			err_hash=nil
			Mongooz::Base.collection(options) do |col|
				err_hash=col.update({:_id=>bson_id}, raw_hash, options)
			end

			err_hash
		end

		def db_save!(options={})
			success=false;
			id=self[:_id] || self['_id']
			if id.nil?
				db_insert(self, options)
				success=true
			else
				err_hash=db_update(id, self, options)
				success=err_hash['n'].to_i > 0
			end

			success
		end
	end
end
