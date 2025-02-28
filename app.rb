# frozen_string_literal: true

require_relative 'lib/key_manager'
require_relative 'utils/response_utils'
require 'sinatra'

$key_manager = KeyManager.new

class KeyServer < Sinatra::Base
  # Endpoint to generate a new key
  post '/key/generate' do
    $key_manager.generate_key
    create_response('success')
  end

  # Endpoint to get an available key
  #
  # @return [String] returns the allocated key or an error message.
  post '/key/allocate' do
    key = $key_manager.get_available_key
    return create_response('no keys available', 404) if key.nil?

    return create_response(key.to_hash)
  end

  # Endpoint to release a key
  #
  # @return [String] returns success or an error message.
  patch '/key/:key' do
    response = $key_manager.release_key(params[:key])

    return create_response('success') if response

    create_response('invalid key', 404)
  end

  # Endpoint to remove a key
  #
  # @return [String] returns success or an error message.
  delete '/key/:key' do
    response = $key_manager.remove_key(params[:key])

    return create_response('success') if response

    create_response('invalid key', 404)
  end

  # Endpoint to keep a key alive
  #
  # @return [String] returns the updated key or an error message.
  patch '/key/:key/alive' do
    updated_key = $key_manager.keep_alive(params[:key])

    return create_response(updated_key.to_hash) if updated_key

    create_response('invalid key', 404)
  end

  # Endpoint to get all key data from the store
  #
  # @return [String] returns the status of the store.
  get '/status' do
    create_response($key_manager.to_hash)
  end
end
