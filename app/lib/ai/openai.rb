module AI
	module OpenAI
		def self.model
			Config::AI::OpenAI::MODEL
		end

		def self.completion(prompt)
			result = $openai.chat(
				parameters: {
					model: Config::AI::OpenAI::MODEL,
					response_format: { "type": "json_object" },
					messages: [{ role: "user", content: prompt }]
				}
			)
			result = result.dig("choices", 0, "message", "content")
			JSON.parse(result).dig('results')
		end
	end
end
