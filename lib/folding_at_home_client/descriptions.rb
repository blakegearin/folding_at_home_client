# frozen_string_literal: true

module FoldingAtHomeClient
  module Descriptions
    extend Request

    def self.all
      endpoint = '/project/description'

      request_and_instantiate_objects(endpoint:, object_class: Description)
    end
  end
end
