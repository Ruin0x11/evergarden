require "sinatra"

require "routes/init"
require "lib/szurubooru"

class Evergarden < Sinatra::Base
  enable :raise_errors, :logging
  disable :show_exceptions

  configure do
    set :domain, ENV["SZURUBOORU_HOST"] || "http://bijutsu.nori.daikon"
    set :external_domain, ENV["EXTERNAL_SZURUBOORU_HOST"] || "http://bijutsu.nori.daikon"
    set :username, "nonbirithm"
    set :auth, "auth"
  end

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
    enable :dump_errors
  end

  error Sinatra::NotFound do
    "Not found"
  end

  error do
    env["sinatra.error"].errors
  end
end
