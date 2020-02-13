require "faraday"
require "faraday_middleware"

# Wrapper around a Faraday connection to support szurubooru pagination
class Szurubooru::Connection
  attr_accessor :auto_paginate

  def initialize(url, username, api_token, auto_paginate: false)
    raise "URL cannot be nil" if url.nil?

    @conn = Faraday.new(url: url) do |faraday|
      faraday.request :json
      faraday.request :multipart
      faraday.response :json, content_type: "application/json"
      faraday.authorization :Token, Base64.strict_encode64("#{username}:#{api_token}")
      faraday.headers["Accept"] = "application/json"

      faraday.use Faraday::Request::Retry
      faraday.use Faraday::Response::Logger
      faraday.adapter Faraday.default_adapter
    end

    @auto_paginate = auto_paginate

    @last_response = nil
  end

  def method_missing(name, *args, &block)
    @conn.send(name, *args, &block)
  end

  # Make one or more HTTP GET requests, optionally fetching
  # the next page of results from URL in Link response header based
  # on value in {#auto_paginate}.
  #
  # @param url [String] The path, relative to {#api_endpoint}
  # @param options [Hash] Query and header params for request
  # @param block [Block] Block to perform the data concatination of the
  #   multiple requests. The block is called with two parameters, the first
  #   contains the contents of the requests so far and the second parameter
  #   contains the latest response.
  # @return [Sawyer::Resource]
  def paginate(url, params, &block)
    resp = request(:get, url, params)
    total = params["total"]
    limit = params["limit"]

    if @auto_paginate
      pp @last_response.body["results"].size
      while @last_response.body["results"].size > 0
	params["offset"] = params["offset"] + limit
	@last_response = request(:get, url, params)
	if block_given?
	  yield(resp, @last_response)
	else
	  resp.body["results"].concat(@last_response.body["results"])
	end
      end
    end

    resp
  end

  def request(method, path, params, headers = {})
    pp params
    @last_response = response = @conn.run_request(method, path, params, headers)
    response
  end
end
