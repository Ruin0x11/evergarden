require "lib/szurubooru/to_danbooru2"

class Evergarden < Sinatra::Base
  get "/posts.json", provides: :json do
    limit = (params["limit"] || "100").to_i
    page = (params["page"] || "0").to_i
    tags = params["tags"] || ""
    login = params["login"] || settings.username
    if login.empty?
      login = settings.username
    end
    api_key = params["api_key"] || settings.auth
    if api_key.empty?
      api_key = settings.auth
    end

    options = {
      "offset" => page * limit,
      "limit" => limit
    }

    client = Szurubooru::Client.new(settings.domain,
				    login,
				    api_key)

    # work around a bizzare szurubooru issue where the client service
    # randomly returns a UserNotFound error, but only inside Docker
    resp = nil
    tries = 10
    tries.times do
      resp = client.search_posts(tags, options)
      break if resp.status == 200
      sleep 0.2
    end

    raise resp.inspect unless resp.status == 200

    json resp.body["results"].map { |r| Szurubooru::ToDanbooru2.post(r, settings.external_domain) }
  end

  get "/posts/:id.json", provides: :json do
    login = params["login"] || settings.username
    if login.empty?
      login = settings.username
    end
    api_key = params["api_key"] || settings.auth
    if api_key.empty?
      api_key = settings.auth
    end

    client = Szurubooru::Client.new(settings.domain,
				    username,
				    auth)

    resp = client.get_post(params["id"])

    json Szurubooru::ToDanbooru2.post(resp.body, client.external_domain)
  end
end
