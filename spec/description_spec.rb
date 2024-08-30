# frozen_string_literal: true

require 'spec_helper'

require 'folding_at_home_client/description'

RSpec.describe FoldingAtHomeClient::Description do
  let(:id) { 123 }
  let(:description) { 'test_description' }
  let(:manager) { 'John Doe' }
  let(:projects) { %w[Project1 Project2] }
  let(:modified) { '2018-09-14 00:07:22' }

  subject do
    described_class.new(
      id:,
      description:,
      manager:,
      projects:,
      modified:
    )
  end

  describe '#initialize' do
    it 'sets the id attribute' do
      expect(subject.id).to eq(id)
    end

    it 'sets the body attribute if description is provided' do
      expect(subject.body).to eq(description)
    end

    it 'sets the manager attribute if manager is provided' do
      expect(subject.manager).to eq(manager)
    end

    it 'sets the updated_at attribute if modified is provided' do
      expect(subject.updated_at).to eq(modified)
    end
  end

  describe '#lookup' do
    let(:endpoint) { "/project/description/#{id}" }
    let(:description_hash) { { description:, manager:, modified: } }

    before do
      allow(subject).to receive(:request).with(endpoint:).and_return([description_hash])
    end

    context 'when there is no error in the response' do
      it 'sets the body attribute' do
        subject.lookup
        expect(subject.body).to eq(description_hash[:description])
      end

      it 'sets the manager attribute' do
        subject.lookup
        expect(subject.manager).to eq(description_hash[:manager])
      end

      it 'sets the updated_at attribute' do
        subject.lookup
        expect(subject.updated_at).to eq(description_hash[:modified])
      end

      it 'returns the object itself' do
        expect(subject.lookup).to eq(subject)
      end
    end

    context 'when there is an error in the response' do
      let(:error) { 'An error occurred' }
      let(:description_hash) { { error: } }

      it 'sets the error attribute' do
        subject.lookup
        expect(subject.error).to eq(error)
      end

      it 'does not update other attributes' do
        subject.lookup
        expect(subject.body).to eq(description)
        expect(subject.manager).to eq(manager)
        expect(subject.updated_at).to eq(modified)
      end

      it 'returns the object itself' do
        expect(subject.lookup).to eq(subject)
      end
    end
  end
end
