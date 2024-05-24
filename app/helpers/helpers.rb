module Helpers
	def hash12(s)
		Digest::MD5.new.update(s).hexdigest[0,12]
	end

	def halt(error)
		request.halt(400, {'X-Error': error}, nil)
	end
end
