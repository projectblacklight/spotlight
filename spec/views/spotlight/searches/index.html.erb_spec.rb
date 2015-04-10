require 'spec_helper'

describe 'spotlight/searches/index.html.erb', type: :view do
  let(:exhibit) { stub_model(Spotlight::Exhibit) }

  before do
    allow(view).to receive_messages(update_all_exhibit_searches_path: '/')
    allow(view).to receive(:current_exhibit).and_return(exhibit)
    assign(:exhibit, exhibit)
  end

  describe 'Without searches' do
    it 'disables the update button' do
      assign(:searches, [])
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
be saved as additional browse categories, an Administrator must \
temporarily turn on the Searchable option in the exhibit style section \
of the Administration > Appearance page.)
    end
  end
end
