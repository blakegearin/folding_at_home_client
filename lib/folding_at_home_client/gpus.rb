# frozen_string_literal: true

module FoldingAtHomeClient
  module GPUs
    extend Request

    def self.all
      endpoint = '/gpus'

      request_and_instantiate_objects(endpoint: endpoint, object_class: GPU)
    end
  end
end
