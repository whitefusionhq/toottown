# frozen_string_literal: true

require "bridgetown"
require "toottown/builder"

# @param config [Bridgetown::Configuration::ConfigurationDSL]
Bridgetown.initializer :toottown do |
    config,
    instance_url: nil,
    access_token: nil,
    minutes_to_cache: 1,
    comments_hashtag: "blog"
  |
  # Add default configuration data:
  config.toottown ||= {}
  config.toottown.instance_url ||= instance_url
  config.toottown.access_token ||= access_token
  config.toottown.minutes_to_cache ||= minutes_to_cache
  config.toottown.comments_hashtag ||= comments_hashtag

  if instance_url.blank? || access_token.blank?
    Bridgetown.logger.warn "Toottown", "No instance URL or access token provided"
  else
    config.only :server do
      unless defined?($redis)
        require "redis"
        $redis = Redis.new(url: ENV.fetch("REDIS_URL", nil))
      end

      require "toottown/models/comment"
      require "toottown/models/mastodon_connection"
      require "toottown/routes"
    end
  end

  # Register your builder:
  config.builder Toottown::Builder
end
