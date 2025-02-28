# frozen_string_literal: true

require_relative '../../utils/response_utils'

RSpec.describe 'ResponseUtils' do
  describe '#create_response' do
    it 'returns a valid response' do
      response = create_response('test')
      expect(response).to eq(
        [
          200,
          { 'Content-Type' => 'application/json' },
          { 'response': 'test' }.to_json
        ]
      )
    end
  end
end
