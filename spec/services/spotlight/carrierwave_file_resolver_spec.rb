# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spotlight::CarrierwaveFileResolver do
  let(:masthead) { FactoryBot.create(:masthead) }
  let(:resolver) { described_class.new }

  describe 'finding the file' do
    subject { Riiif::Image.file_resolver.find(masthead.id) }

    it 'is found' do
      expect(subject).to be_kind_of Riiif::File
    end
  end
end
