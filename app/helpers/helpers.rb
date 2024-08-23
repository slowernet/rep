module Helpers
	def hash12(s)
		Digest::MD5.new.update(s).hexdigest[0,12]
	end

	def error(m, code = 400)
		request.halt(code, {'X-Error': m}, nil)
	end
end
