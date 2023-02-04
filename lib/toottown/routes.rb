module Toottown
  class Routes < Bridgetown::Rack::Routes
    priority :low

    route do |r|
      r.on "toottown" do
        conn = Toottown::Models::MastodonConnection.new(instance_url: bridgetown_site.config.toottown.instance_url, access_token: bridgetown_site.config.toottown.access_token)

        r.on "comments" do
          r.get "count" do
            status = conn.tagged_status_with_link_url(url: params[:url])
            { count: status ? conn.replies_count_of_status(status): 0 }
          end

          r.get do
            replies = conn.replies_of_tagged_status_with_link_url(url: params[:url])
            "<toottown-comments>#{replies.map(&:call).join}</toottown-comments>"
          end
        end
      end
    end
  end
end
