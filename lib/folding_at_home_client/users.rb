# frozen_string_literal: true

module FoldingAtHomeClient
  module Users
    extend self

    def count
      endpoint = "/user-count"

      request(endpoint: endpoint).first
    end

    def top(month: nil, year: nil)
      endpoint = "/user"
      params = {}

      if month && year
        endpoint += "/monthly"
        params = {
          month: month,
          year: year,
        }
      end

      request(endpoint: endpoint, params: params).map do |user_data|
        User.new(**user_data)
      end
    end

    private

    def request(endpoint:, params: {})
      Request.new(endpoint: endpoint, params: params).body
    end
  end
end
