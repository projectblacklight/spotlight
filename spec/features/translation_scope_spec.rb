# frozen_string_literal: true

describe 'Translations scope setting', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:other_exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }

  describe 'exhibit route set' do
    before do
      login_as exhibit_curator
      FactoryBot.create(:translation, exhibit: exhibit)
      FactoryBot.create(:translation, exhibit: other_exhibit)
    end

    it 'default scope of Translation should be limited to current exhibit' do
      visit spotlight.exhibit_path(exhibit)
      expect(Translation.all.count).to eq 1
    end
  end

  describe 'without the context of an exhibit' do
    it 'renders page ok' do
      visit root_path
      expect(page).to have_css '.site-title', text: 'Blacklight'
    end
  end
end
