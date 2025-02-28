# frozen_string_literal: true

def create_response(data, status = 200)
  data = { 'response': data } if data.is_a?(String)

  [status,
   { 'Content-Type' => 'application/json' },
   data.to_json]
end
