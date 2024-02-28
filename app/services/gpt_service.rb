# frozen_string_literal: true

# GptService
class GptService
  include ActiveModel::Serializers::JSON
  include PromptAssistantConcern

  def generate_response(from, body)
    client = OpenAI::Client.new

    user_prompt = "
      From: #{from}

      Message Body: #{body}
    "
    # gpt-3.5-turbo-1106 only this model accept json_object
    response = client.chat(
      parameters: {
        model: 'gpt-3.5-turbo-1106',
        response_format: { type: 'json_object' },
        messages: [
          { role: 'system', content: assistant_prompt },
          { role: 'user', content: user_prompt }
        ],
        temperature: 0.7
      }
    )

    puts "\n\n\n ##################### GPTSERVICE ############# \n\n"
    content = response.dig('choices', 0, 'message', 'content')
    JSON.parse(content)
  end
end
