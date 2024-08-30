# frozen_string_literal: true

require 'spec_helper'

require 'folding_at_home_client/team'
require 'folding_at_home_client/teams'

RSpec.describe FoldingAtHomeClient::Teams do
  describe '.count' do
    let(:endpoint) { '/team/count' }
    let(:response) { 1234 }

    before do
      allow(described_class).to receive(:request).with(endpoint:).and_return([response])
    end

    it 'returns the team count from the API' do
      expect(described_class.count).to eq(response)
      expect(described_class).to have_received(:request).with(endpoint:).once
    end
  end

  describe '.top' do
    let(:month) { 8 }
    let(:year) { 2024 }
    let(:endpoint) { '/team/monthly' }
    let(:params) { { month:, year: } }
    let(:team_object) { instance_double(FoldingAtHomeClient::Team) }

    before do
      allow(described_class).to receive(:request_and_instantiate_objects)
        .with(endpoint:, params:, object_class: FoldingAtHomeClient::Team)
        .and_return([team_object])
    end

    it 'returns an array of Team objects' do
      expect(described_class.top(month:, year:)).to eq([team_object])
      expect(described_class).to have_received(:request_and_instantiate_objects)
        .with(endpoint:, params:, object_class: FoldingAtHomeClient::Team)
        .once
    end
  end
end
