module AI
	module Gemini
		def self.model
			Config::AI::Gemini::MODEL
		end

		def self.completion(prompt)
			begin
				response = $gemini.generate_content({
					contents: {
						role: 'user',
						parts: { text: prompt }
					},
					generation_config: {
						response_mime_type: 'application/json'
					}
				})

				raw_result = response.dig('candidates', 0, 'content', 'parts', 0, 'text')
				JSON.parse(raw_result).dig('results')
			rescue StandardError => e
				puts "Gemini API Error: #{e.message}"
				puts "Error Class: #{e.class}"
				nil # Or return an empty array or error message, etc.
			end
		end
	end
end
