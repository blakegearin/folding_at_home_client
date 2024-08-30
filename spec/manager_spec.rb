# frozen_string_literal: true

require 'spec_helper'

require 'folding_at_home_client/manager'

RSpec.describe FoldingAtHomeClient::Manager do
  let(:id) { 382 }
  let(:name) { 'John Doe' }
  let(:description) { 'test_description' }
  let(:thumb) { 'test_thumb' }
  let(:url) { 'https://test.example' }
  let(:institution) { 'Test Institution' }
  let(:error) { 'Not Found' }

  describe '#initialize' do
    subject do
      described_class.new(
        id:,
        name:,
        description:,
        thumb:,
        url:,
        institution:
      )
    end

    it 'sets the id attribute if provided' do
      expect(subject.id).to eq(id)
    end

    it 'sets the name attribute if provided' do
      expect(subject.name).to eq(name)
    end

    it 'sets the description attribute if provided' do
      expect(subject.description).to eq(description)
    end

    it 'sets the thumb attribute if provided and not empty' do
      expect(subject.thumb).to eq(thumb)
    end

    it 'does not set the thumb attribute if empty' do
      subject = described_class.new(thumb: '')
      expect(subject.thumb).to be_nil
    end

    it 'sets the url attribute if provided and not empty' do
      expect(subject.url).to eq(url)
    end

    it 'does not set the url attribute if empty' do
      subject = described_class.new(url: '')
      expect(subject.url).to be_nil
    end

    it 'sets the institution attribute if provided and not empty' do
      expect(subject.institution).to eq(institution)
    end

    it 'does not set the institution attribute if empty' do
      subject = described_class.new(institution: '')
      expect(subject.institution).to be_nil
    end
  end

  describe '#lookup' do
    let(:endpoint) { "/project/manager/#{id}" }
    let(:manager_hash) do
      {
        name:,
        description:,
        thumb:,
        url:,
        institution:,
      }
    end

    before do
      allow(subject).to receive(:request).with(endpoint:).and_return([manager_hash])
    end

    subject { described_class.new(id:) }

    context 'when there is no error in the response' do
      it 'sets the name attribute' do
        subject.lookup
        expect(subject.name).to eq(manager_hash[:name])
      end

      it 'sets the description attribute' do
        subject.lookup
        expect(subject.description).to eq(manager_hash[:description])
      end

      it 'sets the thumb attribute if not empty' do
        subject.lookup
        expect(subject.thumb).to eq(manager_hash[:thumb])
      end

      it 'sets the url attribute if not empty' do
        subject.lookup
        expect(subject.url).to eq(manager_hash[:url])
      end

      it 'sets the institution attribute if not empty' do
        subject.lookup
        expect(subject.institution).to eq(manager_hash[:institution])
      end

      it 'returns the object itself' do
        expect(subject.lookup).to eq(subject)
      end
    end

    context 'when there is an error in the response' do
      let(:manager_hash) { { error: } }

      it 'sets the error attribute' do
        subject.lookup
        expect(subject.error).to eq(error)
      end

      it 'does not update other attributes' do
        subject.lookup
        expect(subject.name).to be_nil
        expect(subject.description).to be_nil
        expect(subject.thumb).to be_nil
        expect(subject.url).to be_nil
        expect(subject.institution).to be_nil
      end

      it 'returns the object itself' do
        expect(subject.lookup).to eq(subject)
      end
    end
  end
end
