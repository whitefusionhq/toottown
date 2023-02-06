module Toottown
  module Models
    class MastodonConnection
      attr_reader :connection

      def initialize(instance_url:, access_token:)
        @instance_url, @access_token = instance_url, access_token

        @connection = Faraday.new(
          instance_url,
          request: { timeout: 5 },
          headers: {"Authorization" => "Bearer #{access_token}"}
        ) { |f| f.response :json }
      end

      def get(path, **params)
        response = connection.get(path, **params)
        if response.body.is_a?(Array)
          response.body.map(&:with_dot_access)
        else
          response.body.with_dot_access
        end
      end

      def account_id
        @account_id ||= get("/api/v1/accounts/verify_credentials").id
      end

      def tagged_statuses(tagged)
        get("/api/v1/accounts/#{account_id}/statuses", tagged:, exclude_replies: true, exclude_reblogs: true, limit: 40)
      end

      def tagged_status_with_link_url(url:, tagged:)
        results = tagged_statuses(tagged)
        results.find { _1.content.include?(url) }
      end

      def replies_count_of_status(status)
        status.replies_count
      end

      def replies_of_status(status)
        get("/api/v1/statuses/#{status.id}/context").descendants.map { Toottown::Models::Comment.new(status: _1) }
      end

      def replies_of_tagged_status_with_link_url(url:, tagged:)
        status = tagged_status_with_link_url(url:, tagged:)
        return unless status

        [status, replies_of_status(status)]
      end
    end
  end
end
