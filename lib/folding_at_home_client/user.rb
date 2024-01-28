# frozen_string_literal: true

require "cgi"

module FoldingAtHomeClient
  class User
    include Request
    extend Request

    attr_writer :id, :name
    attr_reader :id,
      :name,
      :wus,
      :wus_daily,
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
      wu: nil,
      wus: nil,
      active_7: nil,
      active_50: nil,
      credit: nil,
      last: nil,
      rank: nil,
      score: nil,
      team: nil,
      teams: nil,
      users: nil
    )
      @id = id if id
      @name = name if name

      wus = wu.to_i if wus.nil?
      @wus = wus.to_i if wus

      @active_7 = active_7 if active_7
      @active_50 = active_50 if active_50
      @credit = credit if credit
      @last = last if last
      @rank = rank if rank
      @score = score.to_i if score

      teams = [team] if teams.nil? && team

      teams = teams&.map do |team|
        if team.is_a?(Hash)
          Team.new(**team) unless team[:score].zero?
        elsif team.is_a?(String)
          Team.new(id: team.to_i)
        else
          team
        end
      end&.compact

      @teams = teams if teams
    end

    def lookup(passkey: nil, team_id: nil)
      endpoint = user_endpoint(id: @id, name: @name)

      params = {}
      params[:passkey] = passkey if passkey
      params[:team] = team_id if team_id

      user_hash = nil

      begin
        user_hash = request(endpoint: endpoint, params: params).first
      rescue JSON::ParserError
        if @name
          query_endpoint = "/search/user"
          query_params = {
            query: @name,
          }

          query_user_hash = request(endpoint: query_endpoint, params: query_params).first
          @id = query_user_hash&.fetch(:id, nil)
          user_hash = request(endpoint: user_endpoint, params: params).first if @id
        end
      end

      error = user_hash[:error]

      if error
        @error = error
        return self
      end

      @id = user_hash[:id]
      @name= user_hash[:name]

      @wus_daily = @wus if user_hash[:wus] && !@wus.nil?
      @wus = user_hash[:wus]

      @active_7 = user_hash[:active_7]
      @active_50 = user_hash[:active_50]
      @credit = user_hash[:credit] if user_hash[:credit]
      @last = user_hash[:last]
      @rank = user_hash[:rank]
      @score = user_hash[:score]

      teams = user_hash[:teams]&.map do |team_hash|
        Team.new(**team_hash) unless team_hash[:score].zero?
      end&.compact

      @teams = teams if teams

      self
    end

    def self.lookup(id: nil, name: nil, passkey: nil, team_id: nil)
      user = self.allocate

      user.id ||= id if id
      user.name ||= name if name

      endpoint = user_endpoint(id: user.id, name: user.name)

      params = {}
      params[:passkey] = passkey if passkey
      params[:team] = team_id if team_id

      user_hash = nil

      begin
        user_hash = request(endpoint: endpoint, params: params).first
      rescue JSON::ParserError
        if @name
          query_endpoint = "/search/user"
          query_params = {
            query: @name,
          }

          query_user_hash = request(endpoint: query_endpoint, params: query_params).first
          @id = query_user_hash&.fetch(:id, nil)
          user_hash = request(endpoint: user_endpoint, params: params).first if @id
        end
      end

      error = user_hash[:error]

      if error
        @error = error
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

      teams = user_hash[:teams]&.map do |team_hash|
        Team.new(**team_hash) unless team_hash[:score].zero?
      end&.compact

      user_hash[:teams] = teams if teams

      user.send(:initialize, **user_hash)

      user
    end

    def teams(passkey: nil)
      endpoint = user_endpoint(name_required: true)
      endpoint += "/teams"

      params = {}
      params[:passkey] = passkey if passkey

      teams = request_and_instantiate_objects(
        endpoint: endpoint,
        params: params,
        object_class: Team,
      )

      teams
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

    def user_endpoint(name_required = false)
      if @id && !@id.to_s.empty? && !name_required
        "/uid/#{@id}"
      elsif @name && !@name.empty?
        "/user/#{CGI.escape(@name)}"
      elsif name_required
        raise ArgumentError, "Required: name of user"
      else
        raise ArgumentError, "Required: id or name of user"
      end
    end

    def self.user_endpoint(id: nil, name: nil)
      if id && !id.to_s.empty?
        "/uid/#{id}"
      elsif name && !name.empty?
        "/user/#{CGI.escape(name)}"
      elsif name_required
        raise ArgumentError, "Required: name of user"
      else
        raise ArgumentError, "Required: id or name of user"
      end
    end

  end
end
