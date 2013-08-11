
module Workflows
	
	class WorkflowBase < Mongooz::MongoozHash

		# helper that raises errors if the given symbol is not present in the given hash
		def ensure_hash_has_symbol(hash_to_check, symbol_to_ensure)
			return unless symbol_to_ensure.kind_of?(Symbol) && hash_to_check.kind_of?(Hash)
			raise "Missing required :#{symbol_to_ensure.to_s} hash parameter" unless hash_to_check[symbol_to_ensure]
		end
	end
end
