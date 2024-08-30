# frozen_string_literal: true

require 'spec_helper'

require 'folding_at_home_client/gpu'
require 'folding_at_home_client/gpus'

RSpec.describe FoldingAtHomeClient::GPUs do
  describe '.all' do
    let(:endpoint) { '/gpus' }
    let(:gpu_instances) do
      [
        instance_double(FoldingAtHomeClient::GPU),
        instance_double(FoldingAtHomeClient::GPU),
      ]
    end

    before do
      allow(described_class).to receive(:request_and_instantiate_objects)
        .with(endpoint:, object_class: FoldingAtHomeClient::GPU)
        .and_return(gpu_instances)
    end

    it 'calls request_and_instantiate_objects with the correct endpoint and object class' do
      described_class.all
      expect(described_class).to have_received(:request_and_instantiate_objects)
        .with(endpoint:, object_class: FoldingAtHomeClient::GPU)
    end

    it 'returns the instances created by request_and_instantiate_objects' do
      result = described_class.all
      expect(result).to eq(gpu_instances)
    end
  end
end
