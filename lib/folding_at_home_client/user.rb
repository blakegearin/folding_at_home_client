# frozen_string_literal: true

module FoldingAtHomeClient
  class User
    attr_reader :id,
      :name,
      :wus,
      :active_7,
      :active_50,
      :credit,
      :last,
      :rank,
      :score,
      :teams,
      :error

    def initialize(
      id: nil,
      name: nil,
      wus: nil,
      active_7: nil,
      active_50: nil,
      credit: nil,
      last: nil,
      rank: nil,
      score: nil,
      teams: nil,
      users: nil
    )
      @id = id if id
      @name = name if name

      @wus = wus if wus
      @active_7 = active_7 if active_7
      @active_50 = active_50 if active_50
      @credit = credit if credit
      @last = last if last
      @rank = rank if rank
      @score = score if score

      teams = teams&.map do |team_data|
        Team.new(**team_data) unless team_data[:score].zero?
      end&.compact

      @teams = teams if teams
    end

    def lookup(passkey: nil, team_id: nil)
      params = {}
      params[:passkey] = passkey if passkey
      params[:team] = team_id if team_id

      endpoint = user_endpoint
      user_hash = request(endpoint: endpoint, params: params).first

      if user_hash[:error]
        @error = user_hash[:error]
        return self
      end

      @id = user_hash[:id]
      @name= user_hash[:name]
      @wus = user_hash[:wus]
      @active_7 = user_hash[:active_7]
      @active_50 = user_hash[:active_50]
      @credit = user_hash[:credit]
      @last = user_hash[:last]
      @rank = user_hash[:rank]
      @score = user_hash[:score]

      teams = user_hash[:teams]&.map do |team_data|
        Team.new(**team_data) unless team_data[:score].zero?
      end&.compact

      @teams = teams if teams

      self
    end

    def teams(passkey: nil)
      endpoint = user_endpoint(name_required: true)
      endpoint += "/teams"

      params = {}
      params[:passkey] = passkey if passkey

      request(endpoint: endpoint, params: params).map do |team_data|
        Team.new(**team_data) unless team_data[:score].zero?
      end.compact
    end

    def projects
      endpoint = user_endpoint(name_required: true)
      endpoint += "/projects"

      request(endpoint: endpoint)
    end

    def bonuses(passkey: nil)
      raise ArgumentError, "Required: name of user" unless @name

      endpoint = "/bonus"
      params = {
        user: @name
      }
      params[:passkey] = passkey if passkey

      request(endpoint: endpoint, params: params)
    end

    private

    def request(endpoint:, params: {})
      Request.new(endpoint: endpoint, params: params).body
    end

    def user_endpoint(name_required = false)
      if @id && !@id.empty? && !name_required
        "/uid/#{@id}"
      elsif @name && !@name.empty?
        "/user/#{@name}"
      elsif name_required
        raise ArgumentError, "Required: name of user"
      else
        raise ArgumentError, "Required: id or name of user"
      end
    end
  end
end
