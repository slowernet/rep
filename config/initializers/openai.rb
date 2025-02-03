$openai = OpenAI::Client.new(
	access_token: ENV['OPENAI_API_KEY'],
	log_errors: true
)

module AI
	module OPENAI
		MODEL = 'gpt-4o-mini'
		RESPONSE_FORMAT = { "type": "json_object" }
	end

	ARTICLE_PROMPT = <<~EOT
Please process the below headline-article pairs, returning the following data for each pair:
* A score on a scale 0 to 1 indicating the relevance of the the content to the subject area %{subject_area}
	* Return this as "subject_relevance"
* A score on a scale 0 to 1 indicating the newsworthiness of the the content in the context of the subject area, defined by
	* The number of people likely to be affected by the news
	* The amount of disruption the news could cause
	* How unexpected the news is in the context of the subject area
	* Return this as "newsworthiness"
* An object of describing the strength of association of the content to each of these concepts: %{beat_array} on a scale of 0 to 1
	* Return this as "beat_relevance"
* A one sentence summary of the article content, that
	* does not repeat the language of the headline or the article
	* adds interesting information and detail about the item from the article that is not present in the headline
	* uses a voice indicating some expertise of the content subject area
	* is not prefaced with introductory language like "The piece discusses..." or "The article explores..".

```json
%{json}
```
	EOT
end
