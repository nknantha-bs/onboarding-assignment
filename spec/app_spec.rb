# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe KeyServer do
  before(:each) do
    $key_manager = KeyManager.new
  end

  describe 'POST /key/generate' do
    it 'generates a key' do
      post '/key/generate'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'POST /key/allocate' do
    context 'when key is available' do
      it 'gets an available key' do
        post '/key/generate'
        post '/key/allocate'
        expect(last_response.status).to eq(200)
      end
    end

    context 'when key is not available' do
      it 'returns an error' do
        post '/key/allocate'
        expect(last_response.status).to eq(404)
      end
    end
  end

  describe 'PATCH /key/:key' do
    context 'when key is not expired' do
      it 'releases a key' do
        post '/key/generate'
        post '/key/allocate'
        patch "/key/#{JSON.parse(last_response.body)['key']}"
        expect(last_response.status).to eq(200)
      end
    end

    context 'when key is expired' do
      it 'returns an error' do
        patch '/key/12345'
        expect(last_response.status).to eq(404)
      end
    end
  end

  describe 'DELETE /key/:key' do
    context 'when key is not expired' do
      it 'removes a key' do
        post '/key/generate'
        post '/key/allocate'
        delete "/key/#{JSON.parse(last_response.body)['key']}"
        expect(last_response.status).to eq(200)
      end
    end

    context 'when key is expired' do
      it 'returns an error' do
        delete '/key/12345'
        expect(last_response.status).to eq(404)
      end
    end
  end

  describe 'PATCH /key/:key/alive' do
    context 'when key is not expired' do
      it 'keeps a key alive' do
        post '/key/generate'
        post '/key/allocate'
        patch "/key/#{JSON.parse(last_response.body)['key']}/alive"
        expect(last_response.status).to eq(200)
      end
    end

    context 'when key is expired' do
      it 'returns an error' do
        patch '/key/12345/alive'
        expect(last_response.status).to eq(404)
      end
    end
  end

  it 'gets server status' do
    get '/status'
    expect(last_response.status).to eq(200)
  end
end
