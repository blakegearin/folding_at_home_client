# frozen_string_literal: true

require 'spec_helper'

require 'folding_at_home_client/team'
require 'folding_at_home_client/user'

RSpec.describe FoldingAtHomeClient::User do
  let(:id) { 123 }
  let(:name) { 'John Doe' }
  let(:work_units) { 1500 }
  let(:active7) { 50 }
  let(:active50) { 150 }
  let(:credit) { 2000 }
  let(:last) { '2024-08-29' }
  let(:rank) { 1 }
  let(:score) { 10_000 }
  let(:team) { '1' }
  let(:teams) { [{ id: 1, name: 'Team #1' }] }
  let(:error) { 'Not Found' }

  describe '#initialize' do
    subject do
      described_class.new(
        id:,
        name:,
        work_units:,
        active7:,
        active50:,
        credit:,
        last:,
        rank:,
        score:,
        team:,
        teams:,
        error:
      )
    end

    it 'sets the id attribute' do
      expect(subject.id).to eq(id)
    end

    it 'sets the name attribute' do
      expect(subject.name).to eq(name)
    end

    it 'sets the work_units attribute' do
      expect(subject.work_units).to eq(work_units)
    end

    it 'sets the active7 attribute' do
      expect(subject.active7).to eq(active7)
    end

    it 'sets the active50 attribute' do
      expect(subject.active50).to eq(active50)
    end

    it 'sets the credit attribute' do
      expect(subject.credit).to eq(credit)
    end

    it 'sets the last attribute' do
      expect(subject.last).to eq(last)
    end

    it 'sets the rank attribute' do
      expect(subject.rank).to eq(rank)
    end

    it 'sets the score attribute' do
      expect(subject.score).to eq(score)
    end

    it 'sets the teams attribute' do
      expect(subject.teams).to all(be_an_instance_of(FoldingAtHomeClient::Team))
    end

    it 'sets the error attribute if provided' do
      expect(subject.error).to eq(error)
    end
  end

  describe '#lookup' do
    let(:endpoint) { "/uid/#{id}" }
    let(:user_hash) do
      {
        id:,
        name:,
        wus: work_units,
        active7:,
        active50:,
        credit:,
        last:,
        rank:,
        score:,
        teams:,
      }
    end

    before do
      allow(subject).to receive(:request).with(endpoint:, params: {}).and_return([user_hash])
    end

    subject { described_class.new(id:) }

    context 'when there is no error in the response' do
      it 'sets the attributes correctly' do
        subject.lookup
        expect(subject.id).to eq(id)
        expect(subject.name).to eq(name)
        expect(subject.work_units).to eq(work_units)
        expect(subject.active7).to eq(active7)
        expect(subject.active50).to eq(active50)
        expect(subject.credit).to eq(credit)
        expect(subject.last).to eq(last)
        expect(subject.rank).to eq(rank)
        expect(subject.score).to eq(score)
        expect(subject.teams).to all(be_an_instance_of(FoldingAtHomeClient::Team))
      end

      it 'returns the object itself' do
        expect(subject.lookup).to eq(subject)
      end
    end

    context 'when there is an error in the response' do
      let(:user_hash) { { error: } }

      before do
        allow(subject).to receive(:request).with(endpoint:, params: {}).and_return([user_hash])
      end

      it 'sets the error attribute' do
        subject.lookup
        expect(subject.error).to eq(error)
      end

      it 'does not update other attributes' do
        subject.lookup
        expect(subject.id).to eq(id)
        expect(subject.name).to be_nil
        expect(subject.work_units).to be_nil
        expect(subject.active7).to be_nil
        expect(subject.active50).to be_nil
        expect(subject.credit).to be_nil
        expect(subject.last).to be_nil
        expect(subject.rank).to be_nil
        expect(subject.score).to be_nil
        expect(subject.teams).to be_nil
      end

      it 'returns the object itself' do
        expect(subject.lookup).to eq(subject)
      end
    end
  end

  describe '.find_by' do
    let(:endpoint) { "/uid/#{id}" }
    let(:user_hash) do
      {
        id:,
        name:,
        work_units:,
        active7:,
        active50:,
        credit:,
        last:,
        rank:,
        score:,
        teams:,
      }
    end

    before do
      allow(described_class).to receive(:request).with(endpoint:, params: {}).and_return([user_hash])
    end

    context 'when there is no error in the response' do
      it 'returns the User object with correct attributes' do
        user = described_class.find_by(id:)
        expect(user.id).to eq(id)
        expect(user.name).to eq(name)
        expect(user.work_units).to eq(work_units)
        expect(user.active7).to eq(active7)
        expect(user.active50).to eq(active50)
        expect(user.credit).to eq(credit)
        expect(user.last).to eq(last)
        expect(user.rank).to eq(rank)
        expect(user.score).to eq(score)
        expect(user.teams).to all(be_an_instance_of(FoldingAtHomeClient::Team))
      end
    end

    context 'when there is an error in the response' do
      let(:user_hash) { { error: } }

      before do
        allow(described_class).to receive(:request).with(endpoint:, params: {}).and_return([user_hash])
      end

      it 'sets the error attribute' do
        user = described_class.find_by(id:)
        expect(user.error).to eq(error)
      end

      it 'does not update other attributes' do
        user = described_class.find_by(id:)
        expect(user.id).to eq(id)
        expect(user.name).to be_nil
        expect(user.work_units).to be_nil
        expect(user.active7).to be_nil
        expect(user.active50).to be_nil
        expect(user.credit).to be_nil
        expect(user.last).to be_nil
        expect(user.rank).to be_nil
        expect(user.score).to be_nil
        expect(user.teams).to be_nil
      end
    end
  end

  describe '#teams_lookup' do
    let(:endpoint) { "/user/#{CGI.escape(name)}/teams" }
    let(:teams_array) { [{ id: 1, name: 'Team #1' }] }

    before do
      allow(subject).to receive(:request_and_instantiate_objects)
        .with(endpoint:, params: {}, object_class: FoldingAtHomeClient::Team)
        .and_return(teams_array.map { |team_hash| FoldingAtHomeClient::Team.new(**team_hash) })
    end

    subject { described_class.new(name:) }

    it 'returns an array of Team objects' do
      teams = subject.teams_lookup
      expect(teams).to all(be_an_instance_of(FoldingAtHomeClient::Team))
    end
  end

  describe '#projects' do
    let(:endpoint) { "/user/#{CGI.escape(name)}/projects" }
    let(:projects_array) { [{ id: 1, name: 'Project A' }] }

    before do
      allow(subject).to receive(:request).with(endpoint:).and_return(projects_array)
    end

    subject { described_class.new(name:) }

    it 'returns an array of projects' do
      projects = subject.projects
      expect(projects).to eq(projects_array)
    end
  end

  describe '#bonuses' do
    let(:endpoint) { '/bonus' }
    let(:params) { { user: name } }
    let(:bonuses_array) { [{ bonus: 100 }] }

    before do
      allow(subject).to receive(:request).with(endpoint:, params:).and_return(bonuses_array)
    end

    context 'when name is provided' do
      subject { described_class.new(name:) }

      it 'returns an array of bonuses' do
        bonuses = subject.bonuses
        expect(bonuses).to eq(bonuses_array)
      end
    end

    context 'when name is not provided' do
      it 'raises an ArgumentError' do
        user = described_class.new
        expect { user.bonuses }.to raise_error(ArgumentError, 'Required: name of user')
      end
    end
  end
end
