# frozen_string_literal: true

require 'spec_helper'

require 'folding_at_home_client/version'

RSpec.describe FoldingAtHomeClient do
  describe 'VERSION' do
    it 'has a version number' do
      expect(FoldingAtHomeClient::VERSION).not_to be nil
    end

    it 'is frozen' do
      expect(FoldingAtHomeClient::VERSION).to be_frozen
    end
  end
end
