# frozen_string_literal: true

require 'spec_helper'
require 'faraday'
require 'webmock/rspec'

require 'folding_at_home_client/request'

RSpec.describe FoldingAtHomeClient::Request do
  include FoldingAtHomeClient::Request

  let(:api_url) { 'https://api.foldingathome.org' }
  let(:headers) { { 'Accept' => 'application/json' } }
  let(:endpoint) { '/some_endpoint' }
  let(:params) { { key1: 'value1', key2: 'value2' } }
  let(:response_body) { '[{"id": 1, "name": "test"}]' }

  describe '#connection' do
    it 'sets up a Faraday connection with the correct base URL and options' do
      connection = connection(base_url: api_url)
      expect(connection.url_prefix.to_s.chomp('/')).to eq(api_url.chomp('/'))
      expect(connection.builder.handlers).to include(Faraday::Request::UrlEncoded)
      expect(connection.options.params_encoder).to eq(DoNotEncoder)
    end
  end

  describe '#format_response' do
    let(:response) { double('response', body: response_body) }

    it 'parses the response body as JSON and returns an array of symbols' do
      result = format_response(response)
      expect(result).to eq([{ id: 1, name: 'test' }])
    end

    context 'when the response is not an array' do
      let(:response_body) { '{"id": 1, "name": "test"}' }

      it 'returns an array with a single hash' do
        result = format_response(response)
        expect(result).to eq([{ id: 1, name: 'test' }])
      end
    end
  end

  describe '#request_unencoded' do
    let(:full_url) { "#{api_url}#{endpoint}?#{DoNotEncoder.encode(params)}" }
    let(:response) { double('response', body: response_body) }

    before do
      stub_request(:get, full_url).to_return(status: 200, body: response_body)
    end

    it 'makes an HTTP GET request with unencoded parameters and formats the response' do
      result = request_unencoded(endpoint_and_params: "#{endpoint}?#{DoNotEncoder.encode(params)}")
      expect(result).to eq([{ id: 1, name: 'test' }])
    end

    it 'returns the raw response if format_response is false' do
      result = request_unencoded(endpoint_and_params: "#{endpoint}?#{DoNotEncoder.encode(params)}",
        format_response: false)
      expect(result.body).to eq(response_body)
    end
  end

  describe '#request' do
    let(:full_url) { "#{api_url}#{endpoint}" }

    before do
      stub_request(:get, full_url)
        .with(query: params, headers:)
        .to_return(status: 200, body: response_body)
    end

    it 'makes an HTTP GET request with encoded parameters and formats the response' do
      result = request(endpoint:, params:)
      expect(result).to eq([{ id: 1, name: 'test' }])
    end

    it 'returns the raw response if format_response is false' do
      result = request(endpoint:, params:, format_response: false)
      expect(result.body).to eq(response_body)
    end
  end

  describe '#request_and_instantiate_objects' do
    let(:object_class) do
      Class.new do
        attr_accessor :id, :name

        def initialize(id:, name:)
          @id = id
          @name = name
        end
      end
    end

    let(:response_data) { [{ id: 1, name: 'test' }, { id: 2, name: 'another' }] }
    let(:response_body) { response_data.to_json }

    before do
      stub_request(:get, "#{api_url}#{endpoint}")
        .with(query: params, headers:)
        .to_return(status: 200, body: response_body)
    end

    it 'makes an HTTP GET request and instantiates objects from the response' do
      result = request_and_instantiate_objects(endpoint:, object_class:, params:)
      expect(result.map(&:class)).to all(eq(object_class))
      expect(result.map(&:id)).to match_array(response_data.map { |data| data[:id] })
      expect(result.map(&:name)).to match_array(response_data.map { |data| data[:name] })
    end
  end
end
