# frozen_string_literal: true

$stdout.sync = true
$stderr.sync = true

require 'sinatra/base'
require 'json'
require 'securerandom'

class Server < Sinatra::Base
  get '/' do
    if params[:fail]
      status(500)
      body(nil)
    else
      status(200)
      body(JSON.dump(token: SecureRandom.hex(6)))
    end
  end
end

run Server
