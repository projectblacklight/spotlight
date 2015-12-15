require 'spec_helper'

describe 'shared/_masthead', type: :view do
  let(:exhibit) { FactoryGirl.create(:exhibit, subtitle: 'Some exhibit') }
  let(:masthead) { nil }

  before do
    stub_template 'shared/_exhibit_navbar.html.erb' => 'navbar'

    allow(view).to receive_messages(current_exhibit: exhibit,
                                    current_masthead: masthead,
                                    resource_masthead?: false)
  end

  it 'has the site title and subtitle' do
    render

    expect(rendered).to have_selector '.h1', text: exhibit.title
    expect(rendered).to have_selector 'small', text: exhibit.subtitle
  end

  context 'for an exhibit without a subtitle' do
    before do
      exhibit.update(subtitle: nil)
    end

    it 'does not include the subtitle' do
      render

      expect(rendered).not_to have_selector 'small'
    end
  end

  it 'includes a navbar' do
    render

    expect(rendered).to have_content 'navbar'
  end

  context 'with an exhibit masthead' do
    let(:masthead) { FactoryGirl.create(:masthead) }

    before do
      exhibit.masthead = masthead
      exhibit.save
    end

    it 'adds a class to the masthead' do
      render

      expect(rendered).to have_selector '.masthead.image-masthead'
    end

    it 'has a background image' do
      render

      expect(rendered).to have_selector '.background-container'
      expect(rendered).to have_selector '.background-container-gradient'

      expect(rendered).to match(/background-image: url\('#{masthead.image.cropped.url}'\)/)
    end
  end

  context 'with a resource masthead' do
    let(:masthead) { FactoryGirl.create(:masthead) }

    before do
      allow(view).to receive_messages(resource_masthead?: true)
    end

    it 'adds a class to the masthead' do
      render

      expect(rendered).to have_selector '.masthead.resource-masthead'
    end

    it 'puts the navbar before the title' do
      render

      expect(rendered.index('navbar')).to be < rendered.index(exhibit.title)
    end
  end
end
