require "set"
require "base64"
require "stringio"

class Szurubooru::Client
  attr_reader :conn, :domain

  def initialize(domain, username, auth)
    @domain = domain

    @conn = Szurubooru::Connection.new(domain, username, auth)
  end

  # Search posts
  #
  # @param query [String] Search term and qualifiers
  # @param options [Hash] Sort and pagination options
  # @option options [Integer] :offset Post offset for pagination.
  # @option options [Integer] :limit Number of items per page
  # @return [Faraday::Response] Search results object
  def search_posts(query, options = {})
    search "/api/posts", query, options
  end

  def get_post(id)
    @conn.get "/api/post/#{id}"
  end

  def find_tag_by_name(name)
    @conn.get "/api/tag/#{name}"
  end

  def create_tag(tag)
    @conn.post "/api/tags", { "names" => [tag.name], "category" => tag.category }
  end

  private

  def search(path, query, options = {})
    opts = options.merge("query" => query)
    @conn.paginate(path, opts) do |data, last_response|
      data.items.concat last_response.data.items
    end
  end
end
