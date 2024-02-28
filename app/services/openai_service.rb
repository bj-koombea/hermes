# frozen_string_literal: true

# OpenaiService
class OpenaiService
  include PromptAssistantConcern
  include HTTParty
  base_uri 'https://api.openai.com/v1/chat/'

  def generate_response(from, body)
    user_prompt = "
      From: #{from}

      Message Body: #{body}
    "
    # gpt-3.5-turbo-1106 only this model accept json_object
    response = self.class.post('/completions',
    {
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{Rails.application.credentials.openai_api_key}"
      },
      body: {
        model: 'gpt-3.5-turbo-1106',
        response_format: { type: 'json_object' },
        messages: [
          { role: 'system', content: assistant_prompt },
          { role: 'user', content: user_prompt }
        ]
      }.to_json
    })

    puts "\n\n\n ##################### OpenaiService ############# \n\n"
    content = response.dig('choices', 0, 'message', 'content')
    puts content
    JSON.parse(content)
  end
end
