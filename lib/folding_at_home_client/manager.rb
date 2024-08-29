# frozen_string_literal: true

module FoldingAtHomeClient
  class Manager
    include Request

    attr_reader :id,
      :name,
      :description,
      :thumb,
      :url,
      :institution,
      :error

    def initialize(
      id: nil,
      name: nil,
      description: nil,
      thumb: nil,
      url: nil,
      institution: nil
    )
      @id = id if id

      @name = name if name
      @description = description if description
      @thumb = thumb if thumb && !thumb.empty?
      @url = url if url && !url.empty?
      @institution = institution if institution && !institution.empty?
    end

    def lookup
      endpoint = "/project/manager/#{id}"
      manager_hash = request(endpoint:).first

      error = manager_hash[:error]

      if error
        @error = error
        return self
      end

      @name = manager_hash[:name]
      @description = manager_hash[:description]

      thumb = manager_hash[:thumb]
      @thumb = thumb if thumb && !thumb.empty?

      url = manager_hash[:url]
      @url = url if url && !url.empty?

      institution = manager_hash[:institution]
      @institution = institution if institution && !institution.empty?

      self
    end
  end
end
