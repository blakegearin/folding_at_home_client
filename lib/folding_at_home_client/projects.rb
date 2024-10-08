# frozen_string_literal: true

module FoldingAtHomeClient
  module Projects
    extend Request

    def self.all
      endpoint = '/project'

      request_and_instantiate_objects(endpoint:, object_class: Project)
    end
  end
end
