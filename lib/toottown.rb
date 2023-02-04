# frozen_string_literal: true

require "bridgetown"
require "toottown/builder"

# @param config [Bridgetown::Configuration::ConfigurationDSL]
Bridgetown.initializer :toottown do |config, instance_url: nil, access_token: nil|
  # Add code here which will run when a site includes
  # `init :toottown`
  # in its configuration

  # Add default configuration data:
  config.toottown ||= {}
  config.toottown.instance_url ||= instance_url
  config.toottown.access_token ||= access_token

  if instance_url.blank? || access_token.blank?
    Bridgetown.logger.warn "Toottown", "No instance URL or access token provided"
  else
    config.only :server do
      require "toottown/models/comment"
      require "toottown/models/mastodon_connection"
      require "toottown/routes"
    end
  end

  # Register your builder:
  config.builder Toottown::Builder
end
