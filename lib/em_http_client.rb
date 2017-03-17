# frozen_string_literal: true
require 'json'
require 'eventmachine'
require 'em-synchrony'
require 'em-synchrony/em-http'

class EmHttpClient
  def request(requests: {}, options: {})
    results = Hash.new(nil)

    EM.synchrony do
      multi = EventMachine::Synchrony::Multi.new

      requests.each_pair do |key, req|
        multi.add key, EM::HttpRequest.new(req[:url], options).send(
          req[:method],
          req[:data]
        )
      end

      response = multi.perform

      if response
        response.requests.each_pair do |key, response|
          results[key] = handle_response(response)
        end
      end

      EM.stop
    end

    results
  end

  private

  def is_json?(string)
    begin
      return false unless string.respond_to(:to_str)
      JSON.parse(string).all?
    rescue JSON::ParserError
      false
    end
  end

  def handle_response(response)
    response_code = response.response_header.status

    {
      code: response_code,
      body: response.response
    }
  end
end


if __FILE__ == $0
end
