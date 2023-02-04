# frozen_string_literal: true

module Toottown
  class Builder < Bridgetown::Builder
    def build
      liquid_tag "toottown" do
        "This plugin works!"
      end
    end
  end
end
