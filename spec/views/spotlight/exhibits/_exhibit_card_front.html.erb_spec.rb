require 'spec_helper'

describe 'spotlight/exhibits/_exhibit_card_front.html.erb', type: :view do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:p) { 'spotlight/exhibits/exhibit_card_front' }

  context 'for an exhibit without a thumbnail' do
    before do
      exhibit.update(thumbnail_id: nil)
    end

    it 'has a placeholder thumbnail' do
      render p, exhibit: exhibit

      expect(rendered).to have_selector 'img.default-thumbnail'
    end
  end

  it 'has a thumbnail' do
    render p, exhibit: exhibit

    expect(rendered).to have_selector 'img'
  end

  it 'has a title' do
    render p, exhibit: exhibit

    expect(rendered).to have_selector '.card-title', text: exhibit.title
  end

  context 'for an unpublished exhibit' do
    before do
      exhibit.update(published: false)
    end

    it 'has an unpublished banner' do
      render p, exhibit: exhibit

      expect(rendered).to have_selector '.label.unpublished', text: 'Unpublished'
    end
  end
end
