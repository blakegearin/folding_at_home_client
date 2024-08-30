# frozen_string_literal: true

require 'spec_helper'

require 'folding_at_home_client/team'
require 'folding_at_home_client/user'

RSpec.describe FoldingAtHomeClient::Team do
  let(:id) { 123 }
  let(:name) { 'Team #1' }
  let(:rank) { 1 }
  let(:score) { 10_000 }
  let(:tscore) { 5000 }
  let(:wus) { 500 }
  let(:founder) { 'John Doe' }
  let(:url) { 'https://test.example' }
  let(:logo) { 'https://logo.example' }
  let(:error) { 'Not Found' }

  let(:team_params) do
    {
      id:,
      name:,
      rank:,
      score:,
      tscore:,
      wus:,
      founder:,
      url:,
      logo:,
      error:,
    }
  end

  describe '#initialize' do
    subject { described_class.new(**team_params) }

    it 'sets the id attribute' do
      expect(subject.id).to eq(id)
    end

    it 'sets the name attribute' do
      expect(subject.name).to eq(name)
    end

    it 'sets the rank attribute if provided' do
      expect(subject.rank).to eq(rank)
    end

    it 'sets the score attribute to tscore if provided' do
      expect(subject.score).to eq(tscore)
    end

    it 'sets the user_score attribute if provided' do
      expect(subject.user_score).to eq(score)
    end

    it 'sets the wus attribute if provided' do
      expect(subject.wus).to eq(wus)
    end

    it 'sets the founder attribute if provided' do
      expect(subject.founder).to eq(founder)
    end

    it 'sets the url attribute if provided' do
      expect(subject.url).to eq(url)
    end

    it 'sets the logo attribute if provided' do
      expect(subject.logo).to eq(logo)
    end

    it 'sets the error attribute if provided' do
      expect(subject.error).to eq(error)
    end
  end

  describe '#find_by' do
    let(:endpoint_and_params) { "/team/#{id}" }
    let(:team_hash) do
      {
        id:,
        name:,
        rank:,
        score:,
        tscore:,
        wus:,
        founder:,
        url:,
        logo:,
        error:,
      }
    end

    before do
      allow(described_class).to receive(:request_unencoded).with(endpoint_and_params:).and_return([team_hash])
    end

    subject { described_class.find_by(id:) }

    context 'when there is no error in the response' do
      it 'returns the Team object with correct attributes' do
        expect(subject.id).to eq(id)
        expect(subject.name).to eq(name)
        expect(subject.rank).to eq(rank)
        expect(subject.score).to eq(tscore)
        expect(subject.user_score).to eq(score)
        expect(subject.wus).to eq(wus)
        expect(subject.founder).to eq(founder)
        expect(subject.url).to eq(url)
        expect(subject.logo).to eq(logo)
      end
    end

    context 'when there is an error in the response' do
      let(:team_hash) { { error: } }

      it 'sets the id and error attribute' do
        expect(subject.id).to eq(id)
        expect(subject.error).to eq(error)
      end

      it 'does not update other attributes' do
        expect(subject.name).to be_nil
        expect(subject.rank).to be_nil
        expect(subject.score).to be_nil
        expect(subject.wus).to be_nil
        expect(subject.founder).to be_nil
        expect(subject.url).to be_nil
        expect(subject.logo).to be_nil
      end
    end
  end

  describe '#members' do
    let(:endpoint) { "/team/#{id}/members" }
    let(:keys) { %i[id name] }
    let(:members_array) do
      [
        keys,
        [1, 'User One'],
        [2, 'User Two'],
      ]
    end
    let(:user_names) { ['User One', 'User Two'] }

    before do
      allow(subject).to receive(:request).with(endpoint:).and_return(members_array)
    end

    subject { described_class.new(id:) }

    it 'returns an array of User objects' do
      members = subject.members
      expect(members).to all(be_an_instance_of(FoldingAtHomeClient::User))
    end

    it 'sets the name attribute for each User object' do
      members = subject.members
      expect(members.map(&:name)).to match_array(user_names)
    end
  end
end
