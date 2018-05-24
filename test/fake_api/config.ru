# frozen_string_literal: true

$stdout.sync = true
$stderr.sync = true

require 'sinatra/base'
require 'json'
require 'securerandom'

class Server < Sinatra::Base
  get '/' do
    status 200
    body JSON.dump(
      token: SecureRandom.hex(6)
    )
  end
end

run Server
