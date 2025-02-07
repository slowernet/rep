module AI
	module OpenAI
		def self.model
			Config::AI::OpenAI::MODEL
		end

		def self.completion(prompt)
			begin
				result = $openai.chat(
					parameters: {
						model: Config::AI::OpenAI::MODEL,
						response_format: { "type": "json_object" },
						messages: [{ role: "user", content: prompt }]
					}
				)
# puts result
				result = result.dig("choices", 0, "message", "content")
				result = JSON.parse(result)
				result.dig('results')	# was sometimes returning under "data"?
			rescue Faraday::Error => e
				raise e
			end
		end
	end
end
