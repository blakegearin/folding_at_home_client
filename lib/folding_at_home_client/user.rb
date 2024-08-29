# frozen_string_literal: true

require 'cgi'

module FoldingAtHomeClient
  class User
    include Request
    extend Request

    attr_accessor :id, :name
    attr_reader :work_units,
      :wus_daily,
      :active7,
      :active50,
      :credit,
      :last,
      :rank,
      :score,
      :teams,
      :error

    # rubocop:disable Lint/UnusedMethodArgument
    def initialize(
      id: nil,
      name: nil,
      work_unit: nil,
      work_units: nil,
      active7: nil,
      active50: nil,
      credit: nil,
      last: nil,
      rank: nil,
      score: nil,
      team: nil,
      teams: nil,
      users: nil,
      error: nil
    )
      @id = id if id
      @name = name if name

      work_units = work_unit&.to_i if work_units.nil?
      @work_units = work_units&.to_i if work_units

      @active7 = active7 if active7
      @active50 = active50 if active50
      @credit = credit if credit
      @last = last if last
      @rank = rank if rank
      @score = score.to_i if score

      teams = [team] if teams.nil? && team

      teams = teams&.map do |team_thing|
        if team_thing.is_a?(Hash)
          Team.new(**team_thing) unless team_thing[:score].zero?
        elsif team_thing.is_a?(String)
          Team.new(id: team_thing.to_i)
        else
          team_thing
        end
      end&.compact

      @teams = teams if teams

      @error = error if error
    end
    # rubocop:enable Lint/UnusedMethodArgument

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
          query_endpoint = '/search/user'
          query_params = { query: @name }

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
      @name = user_hash[:name]

      @work_units_daily = @work_units if user_hash[:wus] && !@work_units.nil?
      @work_units = user_hash[:wus]

      @active7 = user_hash[:active7]
      @active50 = user_hash[:active50]
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

    def self.find_by(id: nil, name: nil, passkey: nil, team_id: nil)
      user = allocate

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
        if user.name
          query_endpoint = '/search/user'
          query_params = { query: user.name }

          query_user_hash = request(endpoint: query_endpoint, params: query_params).first
          @id = query_user_hash&.fetch(:id, nil)
          user_hash = request(endpoint: user_endpoint, params: params).first if @id
        end
      end

      error = user_hash[:error]

      if error
        user_hash.delete(:status)

        user.send(:initialize, **user_hash)
        return user
      end

      @id = user_hash[:id]
      @name = user_hash[:name]
      @work_units = user_hash[:wus]
      @active7 = user_hash[:active7]
      @active50 = user_hash[:active50]
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

    def teams_lookup(passkey: nil)
      endpoint = user_endpoint(name_required: true)
      endpoint += '/teams'

      params = {}
      params[:passkey] = passkey if passkey

      request_and_instantiate_objects(
        endpoint: endpoint,
        params: params,
        object_class: Team
      )
    end

    def projects
      endpoint = user_endpoint(name_required: true)
      endpoint += '/projects'

      request(endpoint: endpoint)
    end

    def bonuses(passkey: nil)
      raise ArgumentError, 'Required: name of user' unless @name

      endpoint = '/bonus'
      params = {
        user: @name
      }
      params[:passkey] = passkey if passkey

      request(endpoint: endpoint, params: params)
    end

    class << self
      private

      def user_endpoint(id: nil, name: nil)
        if id && !id.to_s.empty?
          "/uid/#{id}"
        elsif name && !name.empty?
          "/user/#{CGI.escape(name)}"
        elsif name_required
          raise ArgumentError, 'Required: name of user'
        else
          raise ArgumentError, 'Required: id or name of user'
        end
      end
    end

    private

    def user_endpoint(name_required: false)
      if @id && !@id.to_s.empty? && !name_required
        "/uid/#{@id}"
      elsif @name && !@name.empty?
        "/user/#{CGI.escape(@name)}"
      elsif name_required
        raise ArgumentError, 'Required: name of user'
      else
        raise ArgumentError, 'Required: id or name of user'
      end
    end
  end
end
