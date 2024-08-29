# frozen_string_literal: true

module FoldingAtHomeClient
  module Managers
    extend Request

    def self.all
      endpoint = '/project/manager'

      request_and_instantiate_objects(endpoint:, object_class: Manager)
    end
  end
end
