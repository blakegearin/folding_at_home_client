# frozen_string_literal: true

module FoldingAtHomeClient
  class Team
    attr_reader :id,
      :name,
      :trank,
      :tscore,
      :twus,
      :founder,
      :url,
      :logo,
      :score,
      :wus

    def initialize(
      id: nil,
      team:,
      name:,
      trank:,
      tscore:,
      twus:,
      founder:,
      score:,
      wus:,
      url: nil,
      logo: nil,
      last: nil,
      active_7: nil,
      active_50: nil
    )
      @id = id || team
      @name = name if name

      @rank = trank if trank
      @team_score = tscore if tscore
      @team_wus = twus if twus

      @founder = founder if founder
      @url = url if url
      @logo = logo if logo

      @user_score = score if score
      @user_wus = wus if wus
    end
  end
end
