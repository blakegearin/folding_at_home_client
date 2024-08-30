# frozen_string_literal: true

require 'spec_helper'

require 'folding_at_home_client/gpu'

RSpec.describe FoldingAtHomeClient::GPU do
  let(:vendor) { 4098 }
  let(:device) { 4868 }
  let(:type) { 1 }
  let(:species) { 2 }
  let(:description) { 'Kaveri [Radeon Mobility]' }
  let(:error) { 'Not Found' }

  describe '#initialize' do
    subject do
      described_class.new(
        vendor:,
        device:,
        type:,
        species:,
        description:,
        error:
      )
    end

    it 'sets the vendor attribute' do
      expect(subject.vendor).to eq(vendor)
    end

    it 'sets the device attribute' do
      expect(subject.device).to eq(device)
    end

    it 'sets the type attribute if provided' do
      expect(subject.type).to eq(type)
    end

    it 'sets the species attribute if provided' do
      expect(subject.species).to eq(species)
    end

    it 'sets the description attribute if provided' do
      expect(subject.description).to eq(description)
    end

    it 'sets the error attribute if provided' do
      expect(subject.error).to eq(error)
    end
  end

  describe '.find_by' do
    let(:endpoint) { "/gpus/#{vendor}/#{device}" }
    let(:gpu_hash) { { type:, species:, description: } }

    before do
      allow(described_class).to receive(:request).with(endpoint:).and_return([gpu_hash])
    end

    context 'when there is no error in the response' do
      it 'returns a GPU object with the correct attributes' do
        gpu = described_class.find_by(vendor:, device:)

        expect(gpu.vendor).to eq(vendor)
        expect(gpu.device).to eq(device)
        expect(gpu.type).to eq(type)
        expect(gpu.species).to eq(species)
        expect(gpu.description).to eq(description)
        expect(gpu.error).to be_nil
      end
    end

    context 'when there is an error in the response' do
      let(:gpu_hash) { { error: 'Not Found', status: 404 } }

      it 'returns a GPU object with the error set' do
        gpu = described_class.find_by(vendor:, device:)

        expect(gpu.vendor).to eq(vendor)
        expect(gpu.device).to eq(device)
        expect(gpu.error).to eq('Not Found')
        expect(gpu.type).to be_nil
        expect(gpu.species).to be_nil
        expect(gpu.description).to be_nil
      end

      it 'does not include the status key in the initialized object' do
        gpu = described_class.find_by(vendor:, device:)

        expect(gpu.instance_variables).not_to include(:@status)
      end
    end
  end
end
