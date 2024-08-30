# frozen_string_literal: true

require 'spec_helper'
require 'time'
require 'tempfile'

require 'folding_at_home_client/user'
require 'folding_at_home_client/users'

RSpec.describe FoldingAtHomeClient::Users do
  let(:tempfile) { Tempfile.new(['daily_user_summary', '.txt']) }
  let(:sample_content) do
    "Fri Aug 30 04:49:48 GMT 2024\n" \
      "name\tscore\twu\tteam\n" \
      "Anonymous\t3683858340389\t150578639\t0\n" \
      "User1\t123456789\t100000\t1\n"
  end

  describe '.count' do
    let(:endpoint) { '/user-count' }
    let(:user_count) { 100 }

    before do
      allow(described_class).to receive(:request).with(endpoint:).and_return([user_count])
    end

    it 'returns the user count' do
      expect(described_class.count).to eq(user_count)
    end
  end

  describe '.top' do
    let(:endpoint) { '/user/monthly' }
    let(:params) { { month: 8, year: 2024 } }
    let(:users_array) { [{ id: 1, name: 'Alice' }, { id: 2, name: 'Bob' }] }

    before do
      allow(described_class).to receive(:request_and_instantiate_objects)
        .with(endpoint:, params:, object_class: FoldingAtHomeClient::User)
        .and_return(users_array.map { |user_hash| FoldingAtHomeClient::User.new(**user_hash) })
    end

    it 'fetches the top users for the given month and year' do
      users = described_class.top(month: 8, year: 2024)
      expect(users).to all(be_an_instance_of(FoldingAtHomeClient::User))
    end
  end

  describe '.update_daily_file' do
    before do
      tempfile.write(sample_content)
      tempfile.rewind

      allow(File).to receive(:open).with(tempfile.path, any_args).and_return(tempfile)
      allow(File).to receive(:open).and_call_original

      allow(Time).to receive(:now).and_return(Time.parse('Fri Aug 30 07:49:48 GMT 2024'))

      allow(URI).to receive(:open).and_return(StringIO.new(sample_content))
    end

    after do
      tempfile.close
      tempfile.unlink
    end

    context 'when the file is older than 3 hours' do
      it 'updates the file' do
        expect(IO).to receive(:copy_stream).with(instance_of(StringIO), tempfile.path)
        described_class.update_daily_file(filepath: tempfile.path)
      end
    end

    context 'when the file is less than 3 hours old' do
      before do
        allow(Time).to receive(:now).and_return(Time.parse('Fri Aug 30 05:49:48 GMT 2024'))
      end

      it 'does not update the file' do
        expect(IO).not_to receive(:copy_stream)
        described_class.update_daily_file(filepath: tempfile.path)
      end
    end

    context 'when force is true' do
      it 'updates the file regardless of age' do
        expect(IO).to receive(:copy_stream).with(instance_of(StringIO), tempfile.path)
        described_class.update_daily_file(filepath: tempfile.path, force: true)
      end
    end
  end

  describe '.daily' do
    let(:user_hash) { { id: 1, name: 'Alice', team: 1 } }
    let(:params) { { limit: 1, sort_by: :score, order: 'desc' } }

    before do
      tempfile.write(sample_content)
      tempfile.rewind

      allow(described_class).to receive(:update_daily_file).and_return(nil)

      allow(File).to receive(:open).with(tempfile.path, any_args).and_call_original
      allow(File).to receive(:foreach).with(tempfile.path).and_call_original
    end

    after do
      tempfile.close
      tempfile.unlink
    end

    it 'returns an array of User objects with correct attributes' do
      expect(described_class).to receive(:update_daily_file).once
      users = described_class.daily(limit: 1, sort_by: :score, order: 'desc', filepath: tempfile.path)
      expect(users).to all(be_an_instance_of(FoldingAtHomeClient::User))
    end

    it 'handles pagination correctly' do
      users = described_class.daily(page: 1, per_page: 1, filepath: tempfile.path)
      expect(users.length).to eq(1)
    end
  end

  describe '.line_to_array' do
    let(:line) { "1\tAlice\t1\n" }
    let(:expected_array) { %w[1 Alice 1] }

    it 'splits the line into an array' do
      expect(described_class.line_to_array(line)).to eq(expected_array)
    end
  end
end
