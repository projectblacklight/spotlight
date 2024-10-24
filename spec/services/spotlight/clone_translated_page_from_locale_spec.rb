# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spotlight::CloneTranslatedPageFromLocale do
  subject(:clone) { described_class.call(locale: language.locale, page:) }

  let(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:page) { FactoryBot.create(:feature_page, exhibit:) }
  let!(:language) { FactoryBot.create(:language, locale: 'es', exhibit:) }

  it 'clones the exhibit home page for a particular exhibit' do
    expect(Spotlight::Page.where(locale: 'es')).not_to be_present
    expect { clone.save }.to change(Spotlight::Page, :count).by(1)
    expect(Spotlight::Page.unscope(:order).last.locale).to eq 'es'
  end

  context 'when a translated page already exists for that locale' do
    let(:translated_page) { page.clone_for_locale('es') }

    it 'destroys it first' do
      expect(Spotlight::Page.where(locale: 'es')).not_to be_present
      translated_page.save!
      expect(Spotlight::Page.where(locale: 'es').count).to eq 1
      expect { clone.save! }.not_to change(Spotlight::Page, :count) # because it deletes one and adds one
      expect(Spotlight::Page.where(locale: 'es').count).to eq 1
      expect(Spotlight::Page.unscope(:order).last.locale).to eq 'es'
    end
  end
end
