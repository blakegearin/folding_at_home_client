# frozen_string_literal: true

module FoldingAtHomeClient
  module Teams
    extend Request

    def self.count
      endpoint = '/team/count'

      request(endpoint:).first
    end

    def self.top(month: nil, year: nil)
      endpoint = '/team/monthly'
      params = {
        month:,
        year:,
      }

      request_and_instantiate_objects(
        endpoint:,
        params:,
        object_class: Team
      )
    end
  end
end
