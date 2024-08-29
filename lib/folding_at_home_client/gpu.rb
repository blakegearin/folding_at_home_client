# frozen_string_literal: true

module FoldingAtHomeClient
  class GPU
    extend Request

    attr_reader :vendor,
      :device,
      :type,
      :species,
      :description,
      :error

    def initialize(
      vendor: nil,
      device: nil,
      type: nil,
      species: nil,
      description: nil,
      error: nil
    )
      @vendor = vendor
      @device = device
      @type = type if type
      @species = species if species
      @description = description if description

      @error = error if error
    end

    def self.find_by(vendor:, device:)
      endpoint = "/gpus/#{vendor}/#{device}"
      gpu_hash = request(endpoint: endpoint).first

      gpu_hash[:vendor] = vendor
      gpu_hash[:device] = device

      error = gpu_hash[:error]
      gpu_hash.delete(:status) if error

      new_gpu = allocate
      new_gpu.send(:initialize, **gpu_hash)

      new_gpu
    end
  end
end
