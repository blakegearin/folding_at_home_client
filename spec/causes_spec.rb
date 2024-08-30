# frozen_string_literal: true

require 'spec_helper'

require 'folding_at_home_client/causes'

RSpec.describe FoldingAtHomeClient::Causes do
  describe '.all' do
    let(:endpoint) { '/project/cause' }
    let(:response) { { data: 'some_response_data' } }

    before do
      allow(described_class).to receive(:request).with(endpoint:).and_return(response)
    end

    it 'calls the request method with the correct endpoint' do
      described_class.all
      expect(described_class).to have_received(:request).with(endpoint:)
    end

    it 'returns the response from the request method' do
      result = described_class.all
      expect(result).to eq(response)
    end
  end
end
