# frozen_string_literal: true

require 'time'
require 'open-uri'

module FoldingAtHomeClient
  module Users
    extend Request

    DAILY_FILE = 'daily_user_summary.txt'

    def self.count
      endpoint = '/user-count'

      request(endpoint:).first
    end

    def self.top(month: nil, year: nil)
      endpoint = '/user'
      params = {}

      if month && year
        endpoint += '/monthly'
        params = {
          month:,
          year:,
        }
      end

      request_and_instantiate_objects(
        endpoint:,
        params:,
        object_class: User
      )
    end

    def self.update_daily_file(filepath: DAILY_FILE, force: false)
      last_timestamp = File.open(filepath, &:readline).chomp
      time_difference_in_hours = (Time.now.utc - Time.parse(last_timestamp)) / 3600

      return unless time_difference_in_hours >= 3.0 || force

      IO.copy_stream(
        URI.open('https://apps.foldingathome.org/daily_user_summary.txt'),
        filepath
      )
    end

    def self.daily(params = {})
      update_daily_file(filepath: params[:filepath] || DAILY_FILE)

      header_lines = 2

      position = params[:position]&.to_i || false

      unless position
        page = params[:page]&.to_i
        per_page = params[:per_page]&.to_i
        paginating = !page.nil? && !per_page.nil?

        skip_line_index = paginating ? ((page - 1) * per_page) : false

        unless paginating
          limit = params[:limit]&.to_i || 10

          name = params[:name] || false
          team_id = params[:team_id]&.to_i || false
        end
      end

      keys = []
      users = []

      File.foreach(DAILY_FILE).each_with_index do |line, index|
        next if index.zero?

        line_array = line_to_array(line)

        if index == 1
          keys = line_array.map(&:to_sym)
          next
        elsif paginating && (index < (skip_line_index + header_lines))
          next
        end

        user_hash = Hash[keys.zip(line_array)]

        if position
          next unless (position + header_lines) == index

          return User.new(**user_hash)
        elsif name || team_id
          name_match = name ? name == user_hash[:name] : true
          team_match = team_id ? team_id == user_hash[:team].to_i : true

          users.push(User.new(**user_hash)) if name_match && team_match
        else
          users.push(User.new(**user_hash))

          break if paginating && users.length >= per_page
        end

        break if users.length >= limit
      end

      sort_by = params[:sort_by] || false
      users.sort_by! { |user| user.send(sort_by) } if sort_by

      order = params[:order] || false
      users.reverse! if order && order.to_s.downcase == 'desc'

      users
    end

    def self.line_to_array(line)
      line.chomp.split("\t")
    end
  end
end
