# frozen_string_literal: true

module FoldingAtHomeClient
  class Description
    include Request

    attr_reader :id,
      :manager,
      :body,
      :updated_at,
      :error

    def initialize(
      id:,
      description: nil,
      manager: nil,
      projects: nil,
      modified: nil
    )
      @id = id

      @body = description if description
      @manager = manager if manager
      @projects = projects if projects
      @updated_at = modified if modified
    end

    def lookup
      endpoint = "/project/description/#{id}"
      description_hash = request(endpoint: endpoint).first

      error = description_hash[:error]

      if error
        @error = error
        return self
      end

      @body = description_hash[:description]
      @manager = description_hash[:manager]
      @updated_at = description_hash[:modified]

      self
    end
  end
end
