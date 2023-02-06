# frozen_string_literal: true

require_relative "./helper"

class TestToottown < Bridgetown::TestCase
  include Rack::Test::Methods

  REPLIES_FIXTURE = [{"id"=>"109808869101409105", "created_at"=>"2023-02-04T22:39:30.814Z", "in_reply_to_id"=>"109773954858643930", "in_reply_to_account_id"=>"108195559450330916", "sensitive"=>false, "spoiler_text"=>"", "visibility"=>"unlisted", "language"=>"en", "uri"=>"https://indieweb.social/users/jaredwhite/statuses/109808869101409105", "url"=>"https://indieweb.social/@jaredwhite/109808869101409105", "replies_count"=>0, "reblogs_count"=>0, "favourites_count"=>0, "edited_at"=>nil, "favourited"=>false, "reblogged"=>false, "muted"=>false, "bookmarked"=>false, "pinned"=>false, "content"=>"<p>reply test (please ignore 🙃)</p>", "filtered"=>[], "reblog"=>nil, "application"=>{"name"=>"Ivory for iOS", "website"=>"https://tapbots.com/"}, "account"=>{"id"=>"108195559450330916", "username"=>"jaredwhite", "acct"=>"jaredwhite", "display_name"=>"Jared White", "locked"=>false, "bot"=>false, "discoverable"=>true, "group"=>false, "created_at"=>"2022-04-26T00:00:00.000Z", "note"=>"<p>A hearty hello from <a href=\"https://indieweb.social/tags/Portland\" class=\"mention hashtag\" rel=\"tag\">#<span>Portland</span></a> &amp; the Pacific Northwest! 🌲 I&#39;m a b/v+logger, podcaster, <a href=\"https://indieweb.social/tags/Ruby\" class=\"mention hashtag\" rel=\"tag\">#<span>Ruby</span></a> &amp; <a href=\"https://indieweb.social/tags/WebDev\" class=\"mention hashtag\" rel=\"tag\">#<span>WebDev</span></a>-eloper, photographer, and musician.</p><p>I work on <span class=\"h-card\"><a href=\"https://ruby.social/@bridgetown\" class=\"u-url mention\">@<span>bridgetown</span></a></span>, a Ruby web framework. I also talk about ethics in content creation and activism against unregulated generative AI.  Nice to meet you!</p>", "url"=>"https://indieweb.social/@jaredwhite", "avatar"=>"https://cdn.masto.host/indiewebsocial/accounts/avatars/108/195/559/450/330/916/original/b5265e6aace48a28.jpeg", "avatar_static"=>"https://cdn.masto.host/indiewebsocial/accounts/avatars/108/195/559/450/330/916/original/b5265e6aace48a28.jpeg", "header"=>"https://cdn.masto.host/indiewebsocial/accounts/headers/108/195/559/450/330/916/original/389bbeeb5b85f950.jpeg", "header_static"=>"https://cdn.masto.host/indiewebsocial/accounts/headers/108/195/559/450/330/916/original/389bbeeb5b85f950.jpeg", "followers_count"=>1360, "following_count"=>869, "statuses_count"=>1658, "last_status_at"=>"2023-02-04", "noindex"=>false, "emojis"=>[], "fields"=>[{"name"=>"Website", "value"=>"<a href=\"https://jaredwhite.com\" target=\"_blank\" rel=\"nofollow noopener noreferrer me\"><span class=\"invisible\">https://</span><span class=\"\">jaredwhite.com</span><span class=\"invisible\"></span></a>", "verified_at"=>"2022-04-30T17:25:02.602+00:00"}, {"name"=>"Photos on Glass", "value"=>"<a href=\"https://glass.photo/jaredcwhite\" target=\"_blank\" rel=\"nofollow noopener noreferrer me\"><span class=\"invisible\">https://</span><span class=\"\">glass.photo/jaredcwhite</span><span class=\"invisible\"></span></a>", "verified_at"=>nil}, {"name"=>"GitHub", "value"=>"<a href=\"https://github.com/jaredcwhite\" target=\"_blank\" rel=\"nofollow noopener noreferrer me\"><span class=\"invisible\">https://</span><span class=\"\">github.com/jaredcwhite</span><span class=\"invisible\"></span></a>", "verified_at"=>"2023-02-01T18:29:08.969+00:00"}, {"name"=>"Support via ☕️", "value"=>"<a href=\"https://www.buymeacoffee.com/jaredwhite\" target=\"_blank\" rel=\"nofollow noopener noreferrer me\"><span class=\"invisible\">https://www.</span><span class=\"\">buymeacoffee.com/jaredwhite</span><span class=\"invisible\"></span></a>", "verified_at"=>nil}]}, "media_attachments"=>[], "mentions"=>[], "tags"=>[], "emojis"=>[], "card"=>nil, "poll"=>nil}].map(&:with_dot_access)

  # def setup
  #   Bridgetown.reset_configuration!
  #   @config = Bridgetown.configuration(
  #     "root_dir"    => root_dir,
  #     "source"      => source_dir,
  #     "destination" => dest_dir,
  #     "quiet"       => true
  #   )
  #   @config.run_initializers! context: :server
  # end

  def app
    ENV["RACK_ENV"] = "development"
    @@ssr_app ||= Rack::Builder.parse_file(File.expand_path("fixtures/config.ru", __dir__)) # rubocop:disable Style/ClassVars
  end

  def site
    app.opts[:bridgetown_site]
  end

  describe "mastodon model" do
    before do
      app # initialize first

      replies = REPLIES_FIXTURE.map { Toottown::Models::Comment.new(status: _1) }
      @comment = replies.first
    end

    if ENV["RUN_API_CALLS"] # by default, don't ping Mastodon for real!
      it "gets a reply count" do
        conn = Toottown::Models::MastodonConnection.new(instance_url: site.config.toottown.instance_url, access_token: site.config.toottown.access_token)
        url = "https://jaredwhite.com/videos/20230129/portland-vlog-birthday-fun-downtown-washington-park"
        hashtag = "vlog"
        status = conn.tagged_status_with_link_url(url:, tagged: hashtag)
        assert_equal 1, conn.replies_count_of_status(status)
      end

      it "grabs comments from the API" do
        conn = Toottown::Models::MastodonConnection.new(instance_url: site.config.toottown.instance_url, access_token: site.config.toottown.access_token)
        url = "https://jaredwhite.com/videos/20230129/portland-vlog-birthday-fun-downtown-washington-park"
        hashtag = "vlog"
        status, replies = conn.replies_of_tagged_status_with_link_url(url:, tagged: hashtag)

        assert_equal "<p>reply test (please ignore 🙃)</p>", replies.first.content
      end
    end

    it "renders a comment" do
      comment = @comment
      assert_equal "<p>reply test (please ignore 🙃)</p>", comment.content
      assert_equal "jaredwhite", comment.account_name
      assert_equal "https://indieweb.social/@jaredwhite", comment.account_url
      assert_equal "Jared White", comment.display_name
      assert_equal "https://cdn.masto.host/indiewebsocial/accounts/avatars/108/195/559/450/330/916/original/b5265e6aace48a28.jpeg", comment.avatar
      assert_equal "February 4, 2023 @ 2pm →", comment.created_at
      assert_equal "https://indieweb.social/@jaredwhite/109808869101409105", comment.url
    end
  end

  describe "server routes" do
    it "works?" do
      app # initialize first

      get "/toottown/comments/count", url: "https://jaredwhite.com/videos/20230129/portland-vlog-birthday-fun-downtown-washington-park"

      assert last_response.ok?
      assert_equal({ "count" => 1 }, JSON.parse(last_response.body))

      get "/toottown/comments", url: "https://jaredwhite.com/videos/20230129/portland-vlog-birthday-fun-downtown-washington-park"

      assert last_response.ok?
      puts last_response.body

      get "/toottown/comments/count", url: "https://jaredwhite.com/nothing"

      assert last_response.ok?
      assert_equal({ "count" => 0 }, JSON.parse(last_response.body))

      get "/toottown/comments", url: "https://jaredwhite.com/nothing"

      assert last_response.ok?
      assert_equal "", last_response.body

      # assert_equal "<toottown-comments><toottown-comment account-name=\"jaredwhite\" account-url=\"https://indieweb.social/@jaredwhite\" display-name=\"Jared White\" avatar=\"https://cdn.masto.host/indiewebsocial/accounts/avatars/108/195/559/450/330/916/original/b5265e6aace48a28.jpeg\" created-at=\"February 4, 2023\" href=\"https://indieweb.social/@jaredwhite/109808869101409105\"><p>reply test (please ignore 🙃)</p></toottown-comment><toottown-comment account-name=\"konnorrogers@ruby.social\" account-url=\"https://ruby.social/@konnorrogers\" display-name=\"Konnor Rogers\" avatar=\"https://cdn.masto.host/indiewebsocial/cache/accounts/avatars/109/292/491/979/538/244/original/972e900a7a0229e8.jpeg\" created-at=\"February 4, 2023\" href=\"https://ruby.social/@konnorrogers/109808929351487823\"><p><span class=\"h-card\"><a href=\"https://indieweb.social/@jaredwhite\" class=\"u-url mention\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">@<span>jaredwhite</span></a></span> you can’t make me</p></toottown-comment><toottown-comment account-name=\"jaredwhite\" account-url=\"https://indieweb.social/@jaredwhite\" display-name=\"Jared White\" avatar=\"https://cdn.masto.host/indiewebsocial/accounts/avatars/108/195/559/450/330/916/original/b5265e6aace48a28.jpeg\" created-at=\"February 4, 2023\" href=\"https://indieweb.social/@jaredwhite/109808966748772949\"><p><span class=\"h-card\"><a href=\"https://ruby.social/@konnorrogers\" class=\"u-url mention\">@<span>konnorrogers</span></a></span> I may or may not be experimenting with the Mastodon API right about now… 🙈</p></toottown-comment></toottown-comments>", last_response.body
    end
  end
end
