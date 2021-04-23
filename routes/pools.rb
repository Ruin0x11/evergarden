require "lib/szurubooru/to_danbooru2"

class Evergarden < Sinatra::Base
  get "/pools.json", provides: :json do
    name_matches = params["search[name_matches]"] || "*"
    order = params["search[order]"] || "name"
    category = params["search[category]"] || "*"
    login = params["login"] || settings.username
    if login.empty?
      login = settings.username
    end
    api_key = params["api_key"] || settings.auth
    if api_key.empty?
      api_key = settings.auth
    end

    query = "#{name_matches} sort:#{order}"
    options = {
      "category" => category
    }

    client = Szurubooru::Client.new(settings.domain,
				    login,
				    api_key)

    resp = nil
    tries = 10
    tries.times do
      resp = client.search_pools(query, options)
      break if resp.status == 200
      sleep 0.2
    end

    raise resp.inspect unless resp.status == 200

    json resp.body["results"].map { |r| Szurubooru::ToDanbooru2.pool(r, settings.external_domain) }
  end
end
