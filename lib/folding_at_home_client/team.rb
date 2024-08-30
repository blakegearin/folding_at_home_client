# frozen_string_literal: true

module FoldingAtHomeClient
  class Team
    include Request
    extend Request

    attr_accessor :id, :name
    attr_reader :rank,
      :score,
      :wus,
      :founder,
      :url,
      :logo,
      :user_score,
      :user_wus,
      :error

    # rubocop:disable Lint/UnusedMethodArgument
    def initialize(
      id: nil,
      team: nil,
      name: nil,
      wus: nil,
      rank: nil,
      trank: nil,
      credit: nil,
      tscore: nil,
      twus: nil,
      founder: nil,
      score: nil,
      url: nil,
      logo: nil,
      last: nil,
      active_7: nil,
      active_50: nil,
      error: nil
    )
      @id = id || team.to_i if id || team
      @name = name if name

      @rank = trank || rank if trank || rank

      @score = tscore || credit if tscore || credit
      @wus = twus || wus if twus || wus

      @founder = founder if founder
      @url = url if url
      @logo = logo if logo

      @user_score = score if !tscore.nil? && score
      @user_wus = wus if !twus.nil? && wus

      @error = error if error
    end
    # rubocop:enable Lint/UnusedMethodArgument

    def self.find_by(id: nil, name: nil)
      team = allocate

      team.id ||= id if id
      team.name ||= name if name

      endpoint_and_params = '/team'

      if team.id && !team.id.to_s.empty?
        endpoint_and_params += "/#{team.id}"
      elsif team.name && !team.name.empty?
        endpoint_and_params += "/find?name=#{escape_param(team.name)}"
      else
        raise ArgumentError, 'Required: id or name of team'
      end

      team_hash = nil

      begin
        team_hash = request_unencoded(endpoint_and_params:).first
        raise StandardError if team_hash[:error]
      rescue StandardError
        if team.name
          query_endpoint_and_params = "/team?q=#{escape_param(team.name)}"
          query_team_hash = request_unencoded(endpoint_and_params: query_endpoint_and_params).first

          team.id = query_team_hash&.fetch(:id, nil)
          endpoint = "/#{team.id}"

          team_hash = request(endpoint:).first if team.id
        end
      end

      error = team_hash[:error]
      team_hash.delete(:status) if error

      team.send(:initialize, **team_hash)

      team
    end

    def members
      endpoint = "/team/#{@id}/members"

      members_array = request(endpoint:)
      keys = members_array.shift.map(&:to_sym)

      members_array.map do |member_array|
        member_hash = Hash[keys.zip(member_array)]

        User.new(**member_hash)
      end
    end

    def self.escape_param(name)
      name.gsub(' ', '%20').gsub('&', '%26').gsub(',', '%2C')
    end
  end
end
