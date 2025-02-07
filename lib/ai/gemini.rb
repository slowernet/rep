module AI
	module Gemini
		def self.model
			Config::AI::Gemini::MODEL
		end

		def self.completion(prompt)
			# begin
				result = $gemini.generate_content({
					contents: {
						role: 'user',
						parts: { text: prompt }
					},
					generation_config: {
						response_mime_type: 'application/json'
					}
				})
				result = result.dig('candidates', 0, 'content', 'parts', 0, 'text')
# puts result
				JSON.parse(result).dig('results')
			# rescue Exception => error	# ::Gemini::Errors::GeminiError => error
			# 	puts error.class # Gemini::Errors::RequestError
			# 	puts error.message # 'the server responded with status 500'
			# 	puts error.to_json
			# 	# puts error.payload
			# 	# puts error.request
			# end
		end
	end
end
