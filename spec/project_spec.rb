# frozen_string_literal: true

require 'spec_helper'

require 'folding_at_home_client/description'
require 'folding_at_home_client/manager'
require 'folding_at_home_client/project'
require 'folding_at_home_client/user'

RSpec.describe FoldingAtHomeClient::Project do
  let(:id) { 42 }
  let(:description_id) { 1001 }
  let(:manager) { 'John Doe' }
  let(:cause) { 'Cancer Research' }
  let(:modified) { '2018-09-14 00:07:22' }
  let(:mthumb) { 'test_mthumb' }
  let(:mdescription) { 'test_mdescription' }

  describe '#initialize' do
    subject do
      described_class.new(
        id:,
        description: description_id,
        manager:,
        cause:,
        modified:
      )
    end

    it 'sets the id attribute' do
      expect(subject.id).to eq(id)
    end

    it 'sets the description_id attribute if provided' do
      expect(subject.description_id).to eq(description_id)
    end

    it 'sets the manager attribute as a Manager object' do
      expect(subject.manager).to be_an_instance_of(FoldingAtHomeClient::Manager)
      expect(subject.manager.name).to eq(manager)
    end

    it 'sets the cause attribute if provided' do
      expect(subject.cause).to eq(cause)
    end

    it 'sets the updated_at attribute if provided' do
      expect(subject.updated_at).to eq(modified)
    end
  end

  describe '#lookup' do
    let(:endpoint) { "/project/#{id}" }
    let(:project_hash) do
      {
        description: description_id,
        manager:,
        mthumb:,
        mdescription:,
        cause:,
        modified:,
      }
    end

    before do
      allow(subject).to receive(:request).with(endpoint:).and_return([project_hash])
    end

    subject { described_class.new(id:) }

    context 'when there is no error in the response' do
      it 'sets the body attribute' do
        subject.lookup
        expect(subject.instance_variable_get(:@body)).to eq(description_id)
      end

      it 'sets the manager attribute as a Manager object with correct attributes' do
        subject.lookup
        expect(subject.manager.name).to eq(manager)
        expect(subject.manager.thumb).to eq(mthumb)
        expect(subject.manager.description).to eq(mdescription)
      end

      it 'sets the cause attribute' do
        subject.lookup
        expect(subject.cause).to eq(cause)
      end

      it 'sets the updated_at attribute' do
        subject.lookup
        expect(subject.updated_at).to eq(modified)
      end

      it 'returns the object itself' do
        expect(subject.lookup).to eq(subject)
      end
    end

    context 'when there is an error in the response' do
      let(:project_hash) { { error: 'Not Found' } }

      it 'sets the error attribute' do
        subject.lookup
        expect(subject.error).to eq('Not Found')
      end

      it 'does not update other attributes' do
        subject.lookup
        expect(subject.manager).to be_nil
        expect(subject.cause).to be_nil
        expect(subject.updated_at).to be_nil
      end

      it 'returns the object itself' do
        expect(subject.lookup).to eq(subject)
      end
    end
  end

  describe '#contributors' do
    let(:endpoint) { '/project/contributors' }
    let(:params) { { projects: id } }
    let(:contributor_names) { %w[Alice Bob] }

    before do
      allow(subject).to receive(:request).with(endpoint:, params:).and_return(contributor_names)
    end

    subject { described_class.new(id:) }

    it 'returns an array of User objects' do
      contributors = subject.contributors
      expect(contributors).to all(be_an_instance_of(FoldingAtHomeClient::User))
    end

    it 'sets the name attribute for each User object' do
      contributors = subject.contributors
      expect(contributors.map(&:name)).to match_array(contributor_names)
    end
  end

  describe '#description' do
    let(:description_object) { instance_double(FoldingAtHomeClient::Description) }

    subject { described_class.new(id:, description: description_id) }

    before do
      allow(FoldingAtHomeClient::Description).to receive(:new).with(id: description_id).and_return(description_object)
      allow(description_object).to receive(:lookup).and_return(description_object)
    end

    it 'returns the Description object' do
      expect(subject.description).to eq(description_object)
    end

    it 'calls the lookup method on the Description object' do
      subject.description
      expect(description_object).to have_received(:lookup)
    end
  end
end
