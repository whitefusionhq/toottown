require "phlex"

module Toottown
  module Models
    class Comment < Phlex::HTML
      register_element :toottown_comment
      register_element :hgroup # FIXME in Phlex! See: https://github.com/joeldrapper/phlex/pull/477
      attr_reader :status

      def self.styles
        @styles ||= File.read(File.join(__dir__, "comment.css"))
      end

      def initialize(status:)
        @status = status
      end

      def content = status.content

      def account_name = status.account.acct

      def account_url = status.account.url

      def display_name = @status.account.display_name

      def avatar = @status.account.avatar_static

      def created_at = Bridgetown::Utils.parse_date(@status.created_at).strftime("%B %-d, %Y @ %-I%P →")

      def url = @status.url

      def template
        toottown_comment href: url do
          # Shadow DOM:
          template_tag shadowroot: "open", shadowrootmode: "open" do
            header part: "header" do
              a href: account_url, target: "_blank" do
                img part: "avatar", src: avatar
                hgroup do
                  h4(part: "display-name") { display_name }
                  p(part: "account-name") { "@#{account_name}" }
                end
              end
            end
            unsafe_raw content
            footer part: "footer" do
              a(part: "permalink", href: url, target: "_blank") do
                time(part: "created-at", datetime: @status.created_at) { created_at }
              end
            end
            style do
              unsafe_raw self.class.styles
            end
          end
        end
      end
    end
  end
end
