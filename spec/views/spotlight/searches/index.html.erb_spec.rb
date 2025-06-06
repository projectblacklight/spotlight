# frozen_string_literal: true

RSpec.describe 'spotlight/searches/index.html.erb', type: :view do
  let(:exhibit) { stub_model(Spotlight::Exhibit) }
  let(:default_language) { true }

  before do
    allow(view).to receive_messages(update_all_exhibit_searches_path: '/',
                                    exhibit_alt_text_path: '/',
                                    default_language?: default_language)
    allow(view).to receive(:current_exhibit).and_return(exhibit)
    assign(:exhibit, exhibit)
  end

  describe 'Without searches' do
    it 'disables the update button' do
      assign(:searches, [])
      expect(exhibit).to receive(:searchable?).and_return(true)
      render
      expect(rendered).to have_content 'You can save search results'
    end
  end

  describe 'When the exhibit is not searchable' do
    it 'displays a warning' do
      assign(:searches, [])
      expect(exhibit).to receive(:searchable?).and_return(false)
      render
      expect(rendered).to have_css '.alert-warning', text: %(\
This exhibit is not currently searchable. To perform searches that can \
be saved as additional browse categories, \
temporarily turn on the Display search box option in the Options section \
of the Configuration > Search page.)
    end
  end

  describe 'when a locale other than the default is set' do
    let(:default_language) { false }

    before do
      assign(:searches, [])
      allow(exhibit).to receive(:searchable?).and_return(true)
      render
    end

    it 'removes the form and displays a translations message' do
      expect(rendered).to have_text 'Please use the translations editor'
      expect(rendered).to have_no_content 'You can save search results'
    end
  end
end
