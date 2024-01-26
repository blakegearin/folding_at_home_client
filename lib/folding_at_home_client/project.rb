# frozen_string_literal: true

module FoldingAtHomeClient
  class Project
    include Request

    attr_reader :id,
      :description_id,
      :manager,
      :cause,
      :thumb,
      :url,
      :institution,
      :updated_at,
      :error

    def initialize(
      id:,
      description: nil,
      manager: nil,
      cause: nil,
      modified: nil
    )
      @id = id

      @description_id = description if description
      @manager = Manager.new(name: manager) if manager
      @cause = cause if cause
      @updated_at = modified if modified
    end

    def lookup
      endpoint = "/project/#{@id}"
      project_hash = request(endpoint: endpoint).first

      error = project_hash[:error]

      if error
        @error = error
        return self
      end

      @body = project_hash[:description]
      @manager = Manager.new(
        name: project_hash[:manager],
        thumb: project_hash[:mthumb],
        description: project_hash[:mdescription],
      )
      @cause = project_hash[:cause]
      @updated_at = project_hash[:modified]

      self
    end

    def contributors
      endpoint = "/project/contributors"
      params = {
        projects: @id,
      }

      request(endpoint: endpoint, params: params).map do |name|
        User.new(name: name)
      end
    end

    def description
      Description.new(id: @description_id).lookup
    end
  end
end
