require_relative '../ai'

$openai = OpenAI::Client.new(
	access_token: ENV['OPENAI_API_KEY'],
	log_errors: true
)

$gemini = Gemini.new(
	credentials: {
		service: 'generative-language-api',
		api_key: ENV['GEMINI_API_KEY'],
		version: 'v1beta'
	},
	options: {
		model: Config::AI::Gemini::MODEL,
	}
)
