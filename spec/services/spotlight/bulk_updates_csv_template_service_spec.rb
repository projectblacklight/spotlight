# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spotlight::BulkUpdatesCsvTemplateService do
  subject(:service) { described_class.new(exhibit:) }

  let(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:tag1) { FactoryBot.create(:tagging, tagger: exhibit, taggable: exhibit) }
  let!(:tag2) { FactoryBot.create(:tagging, tagger: exhibit, taggable: exhibit) }

  describe '#template' do
    let(:view_context) { double('ViewContext', document_presenter: double('DocumentPresenter', heading: 'Document Title')) }

    it 'has a row for every document (+ the header)' do
      template = CSV.parse(service.template(view_context:).to_a.join)
      expect(template).to have_at_least(56).items
      expect(template[0].join(',')).to match(/Item ID,Item Title,Visibility,Tag: tagging\d,Tag: tagging\d/)
    end

    it 'only has requested columns' do
      template = CSV.parse(service.template(view_context:, tags: false).to_a.join)
      expect(template[0].join(',')).to eq 'Item ID,Item Title,Visibility'
    end
  end
end
