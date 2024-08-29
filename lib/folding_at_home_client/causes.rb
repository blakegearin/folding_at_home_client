# frozen_string_literal: true

module FoldingAtHomeClient
  module Causes
    extend Request

    def self.all
      endpoint = '/project/cause'

      request(endpoint:)
    end
  end
end
