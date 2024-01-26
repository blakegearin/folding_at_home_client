# frozen_string_literal: true

module FoldingAtHomeClient
  module Users
    extend Request

    def self.count
      endpoint = "/user-count"

      request(endpoint: endpoint).first
    end

    def self.top(month: nil, year: nil)
      endpoint = "/user"
      params = {}

      if month && year
        endpoint += "/monthly"
        params = {
          month: month,
          year: year,
        }
      end

      request_and_instantiate_objects(
        endpoint: endpoint,
        params: params,
        object_class: User,
      )
    end
  end
end
