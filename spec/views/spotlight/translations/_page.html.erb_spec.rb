# frozen_string_literal: true

describe 'spotlight/translations/_page.html.erb', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:page) { FactoryBot.create(:feature_page, exhibit: exhibit) }

  before do
    allow(view).to receive_messages(
      clone_exhibit_feature_page_path: '/',
      clone_exhibit_home_page_path: '/',
      current_exhibit: exhibit,
      edit_exhibit_feature_page_path: '/',
      edit_exhibit_home_page_path: '/',
      exhibit_feature_page_path: '/',
      f: instance_double('form', fields_for: {}), # mockform builder
      page: page
    )
    assign(:language, 'es')
  end

  it 'includes a check icon when the page is published' do
    page.published = true
    render

    expect(rendered).to have_css('.glyphicon.glyphicon-ok')
  end

  context 'when there is a translated page' do
    let!(:page_es) { FactoryBot.create(:feature_page, exhibit: exhibit, locale: 'es', default_locale_page: page) }

    it 'links to the translated page' do
      render
      expect(rendered).to have_link(page_es.title)
    end

    it 'includes the data attribute used by the progress tracker' do
      render
      expect(rendered).to have_css('[data-translation-present="true"]')
    end

    context 'when the default locale page has been updated more recently than the translation' do
      before { page_es.update(updated_at: 10.seconds.ago) }

      it 'includes an alert icon' do
        render

        expect(rendered).to have_css('.glyphicon.glyphicon-alert')
      end
    end

    context 'when the page is a home page' do
      let(:page) { exhibit.home_page }
      before { page_es.update(type: 'Spotlight::HomePage') }

      it 'does not render a delete link' do
        render

        expect(rendered).not_to have_link('Delete')
      end
    end
  end

  context 'when there is no translated page' do
    it 'links to create a new one' do
      render
      expect(rendered).to have_content 'No translated page.'
      expect(rendered).to have_link 'Create one now.'
    end

    it 'does not include the data attribute used by the progress tracker' do
      render
      expect(rendered).not_to have_css('[data-translation-present="true"]')
    end
  end
end
