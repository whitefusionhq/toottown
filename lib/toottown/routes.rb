module Toottown
  class Routes < Bridgetown::Rack::Routes
    priority :low

    route do |r|
      r.on "toottown" do
        # NOTE: if you want to wipe out cache easily:
        # $redis.del(*$redis.keys("reply_counts:*"))
        # $redis.del(*$redis.keys("comments:*"))

        response_cache = ->(key, expire_in:, &block) do
          value = $redis.get(key)
          return value if value

          value = block.()
          return unless value

          $redis.set(key, value, ex: expire_in)

          value
        end

        limit_url = ->(url) { url[0...128] }
        hashtag = params[:comments_hashtag] || bridgetown_site.config.toottown.comments_hashtag

        conn = Toottown::Models::MastodonConnection.new(instance_url: bridgetown_site.config.toottown.instance_url, access_token: bridgetown_site.config.toottown.access_token)

        r.on "comments" do
          next (response.status = 400; "Missing URL Parameter") if params[:url].blank?

          url = limit_url.(params[:url])

          r.get "count" do
            count = response_cache.("reply_counts:#{url}", expire_in: bridgetown_site.config.toottown.minutes_to_cache * 60) do
              status = conn.tagged_status_with_link_url(url:, tagged: hashtag)
              status ? conn.replies_count_of_status(status) : nil
            end.to_i

            { count: }
          end

          r.get do
            comments = response_cache.("comments:#{url}", expire_in: bridgetown_site.config.toottown.minutes_to_cache * 60) do
              status, replies = conn.replies_of_tagged_status_with_link_url(url:, tagged: hashtag)
              next unless status

              "<toottown-comments href=\"#{status.url}\">#{replies.map(&:call).join}</toottown-comments>"
            end

            comments ? comments : ""
          end
        end
      end
    end
  end
end
