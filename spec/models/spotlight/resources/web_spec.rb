require 'spec_helper'

describe Spotlight::Resources::Web, type: :model do
  class TestResource < Spotlight::Resource
    include Spotlight::Resources::Web
  end

  subject { TestResource.new }
  describe '.fetch' do
  end

  describe '#harvest!' do
    it 'caches the body and headers in the data' do
      allow(described_class).to receive_messages(fetch: double(body: 'xyz', headers: { a: 1 }))
      subject.harvest!
      expect(subject.data[:body]).to eq 'xyz'
      expect(subject.data[:headers]).to eq a: 1
    end
  end

  describe '#body' do
    it 'returns the body DOM' do
      allow(described_class).to receive_messages(fetch: double(body: '<html />', headers: { a: 1 }))
      expect(subject.body).to be_a_kind_of(Nokogiri::HTML::Document)
    end
  end
end
