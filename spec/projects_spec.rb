# frozen_string_literal: true

require 'spec_helper'

require 'folding_at_home_client/project'
require 'folding_at_home_client/projects'

RSpec.describe FoldingAtHomeClient::Projects do
  describe '.all' do
    let(:endpoint) { '/project' }
    let(:project_instances) do
      [
        instance_double(FoldingAtHomeClient::Project),
        instance_double(FoldingAtHomeClient::Project),
      ]
    end

    before do
      allow(described_class).to receive(:request_and_instantiate_objects)
        .with(endpoint:, object_class: FoldingAtHomeClient::Project)
        .and_return(project_instances)
    end

    it 'calls request_and_instantiate_objects with the correct endpoint and object class' do
      described_class.all
      expect(described_class).to have_received(:request_and_instantiate_objects)
        .with(endpoint:, object_class: FoldingAtHomeClient::Project)
    end

    it 'returns the instances created by request_and_instantiate_objects' do
      result = described_class.all
      expect(result).to eq(project_instances)
    end
  end
end
