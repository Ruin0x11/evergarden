module Szurubooru
  module ToDanbooru2
    def self.post(body, domain)
      tags = body["tags"].map { |tag| { name: tag["names"].first, category: tag["category"].to_sym } }

      {
        id: body["id"],
        tag_string: tag_string(tags),
        tag_string_general: tag_string(tags, :general),
        tag_string_character: tag_string(tags, :character),
        tag_string_copyright: tag_string(tags, :copyright),
        tag_string_artist: tag_string(tags, :artist),
        tag_string_meta: tag_string(tags, :meta),
        source: domain + "/post/" + body["id"].to_s,
        file_url: domain + "/" + body["contentUrl"],
        large_file_url: domain + "/" + body["contentUrl"],
        preview_file_url: domain + "/" + body["thumbnailUrl"],
        rating: rating(body["safety"]),
        image_width: body["canvasWidth"],
        image_height: body["canvasHeight"],
        file_size: body["fileSize"],
        md5: body["checksum"],
        created_at: body["creationTime"],
        updated_at: body["lastEditTime"],
      }
    end

    def self.pool(body, domain)
      post_ids = body["posts"].map { |post| post["id"] }

      {
        id: body["id"],
        name: body["names"][0],
        created_at: body["creationTime"],
        updated_at: body["lastEditTime"],
        category: body["category"],
        post_ids: post_ids,
        post_count: body["postCount"],
        is_active: true,
        is_deleted: false
      }
    end

    private

    def self.tag_string(tags, category = nil)
      list = if category
               tags.filter { |tag| tag[:category] == category }
             else
               tags
             end
      list.map { |tag| tag[:name] }.join(" ")
    end

    def self.rating(safety)
      case safety
      when "safe"
        "s"
      when "sketchy"
        "q"
      when "unsafe"
        "e"
      end
    end
  end
end
