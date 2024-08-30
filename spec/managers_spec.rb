# frozen_string_literal: true

require 'spec_helper'

require 'folding_at_home_client/manager'
require 'folding_at_home_client/managers'

RSpec.describe FoldingAtHomeClient::Managers do
  describe '.all' do
    let(:endpoint) { '/project/manager' }
    let(:manager_instances) do
      [
        instance_double(FoldingAtHomeClient::Manager),
        instance_double(FoldingAtHomeClient::Manager),
      ]
    end

    before do
      allow(described_class).to receive(:request_and_instantiate_objects)
        .with(endpoint:, object_class: FoldingAtHomeClient::Manager)
        .and_return(manager_instances)
    end

    it 'calls request_and_instantiate_objects with the correct endpoint and object class' do
      described_class.all
      expect(described_class).to have_received(:request_and_instantiate_objects)
        .with(endpoint:, object_class: FoldingAtHomeClient::Manager)
    end

    it 'returns the instances created by request_and_instantiate_objects' do
      result = described_class.all
      expect(result).to eq(manager_instances)
    end
  end
end
