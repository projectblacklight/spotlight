# frozen_string_literal: true

describe Spotlight::TitleHelper, type: :helper do
  before do
    allow(helper).to receive_messages(application_name: 'Application')
  end

  describe '#page_title' do
    it 'sets the @page_title ivar' do
      helper.page_title('Section', 'Title')
      title = helper.instance_variable_get(:@page_title)
      expect(title).to eq 'Section - Title | Application'
    end

    it 'renders the section title and the page title' do
      title = helper.page_title('Section', 'Title')
      expect(title).to have_selector 'h1', text: 'Section'
      expect(title).to have_selector 'h1 small', text: 'Title'
    end

    it 'renders just the section title if that was all that was provided' do
      allow(helper).to receive(:t).and_call_original
      allow(helper).to receive(:t).with(:'.header', default: '').and_return('')

      title = helper.page_title('Section')

      expect(title).to have_selector 'h1', text: 'Section'
      expect(title).not_to have_selector 'h1 small'

      title = helper.instance_variable_get(:@page_title)
      expect(title).to eq 'Section | Application'
    end
  end

  describe '#set_html_page_title' do
    it 'assigns the @page_title ivar' do
      allow(helper).to receive_messages(application_name: 'B')
      helper.set_html_page_title 'A'
      title = helper.instance_variable_get(:@page_title)
      expect(title).to eq 'A | B'
    end

    it 'strips out any HTML tags' do
      allow(helper).to receive_messages(application_name: 'B')
      expect(helper.set_html_page_title('<b>text</b> should not include HTML')).to eq 'text should not include HTML | B'
    end
  end

  describe '#curation_page_title' do
    it 'renders a page title in the curation section' do
      title = helper.curation_page_title 'Some title'
      expect(title).to have_selector 'h1', text: 'Curation'
      expect(title).to have_selector 'h1 small', text: 'Some title'
    end
  end

  describe '#configuration_page_title' do
    it 'renders a page title in the configuration section' do
      title = helper.configuration_page_title 'Some title'
      expect(title).to have_selector 'h1', text: 'Configuration'
      expect(title).to have_selector 'h1 small', text: 'Some title'
    end
  end
end
