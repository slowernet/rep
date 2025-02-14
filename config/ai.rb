module AI
	module OpenAI; end
	module Gemini; end
end

module Config
	module AI
		module OpenAI
			MODEL = 'gpt-4o-mini'
			# MODEL = 'gpt-4o'
		end

		module Gemini
			MODEL = 'gemini-2.0-flash'
			# MODEL = 'gemini-1.5-flash'
		end

		ACTIVE_PROVIDER = ::AI::Gemini
		# ACTIVE_PROVIDER = ::AI::OpenAI

		SOURCER_PROMPT = File.read('./config/prompts/sourcer.txt').freeze
		SOURCER_PROMPT_INFO = `TZ=UTC git log -1 --date=format-local:":%Y-%m-%d %H:%M:%S %z" --format="%h %cd" -- config/prompts/sourcer.txt`.strip.freeze
		PICKER_PROMPT = File.read('./config/prompts/picker.txt').freeze
		PICKER_PROMPT_INFO = `TZ=UTC git log -1 --date=format-local:":%Y-%m-%d %H:%M:%S %z" --format="%h %cd" -- config/prompts/picker.txt`.strip.freeze
	end
end
