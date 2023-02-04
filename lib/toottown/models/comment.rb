require "phlex"

module Toottown
  module Models
    class Comment < Phlex::HTML
      register_element :toottown_comment
      attr_reader :status

      def initialize(status:)
        @status = status
      end

      def content = status.content

      def account_name = status.account.acct

      def account_url = status.account.url

      def display_name = @status.account.display_name

      def avatar = @status.account.avatar_static

      def created_at = Bridgetown::Utils.parse_date(@status.created_at).strftime("%B %-d, %Y")

      def url = @status.url

      def template
        toottown_comment(account_name:, account_url:, display_name:, avatar:, created_at:, href: url) do
          unsafe_raw content
        end
      end
    end
  end
end
