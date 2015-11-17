require 'spec_helper'

module Spotlight
  describe 'spotlight/exhibits/index', type: :view do
    let(:exhibits) { Spotlight::Exhibit.none }

    before do
      assign(:exhibits, exhibits)
      allow(view).to receive_messages(exhibit_path: '/')
    end

    context 'with published exhibits' do
      let!(:exhibit_a) { FactoryGirl.create(:exhibit, published: true) }
      let!(:exhibit_b) { FactoryGirl.create(:exhibit, published: true) }
      let!(:exhibit_c) { FactoryGirl.create(:exhibit, published: false) }

      let(:exhibits) { Spotlight::Exhibit.all }

      it 'renders the published exhibits' do
        render

        expect(rendered).to have_selector('.exhibit-card', count: 2)
        expect(rendered).to have_text exhibit_a.title
        expect(rendered).to have_text exhibit_b.title
        expect(rendered).not_to have_text exhibit_c.title
      end
    end

    context 'with an authorized user' do
      let(:current_user) { double }

      before do
        allow(view).to receive_messages(can?: true,
                                        current_user: current_user,
                                        new_exhibit_path: '/exhibits/new')
      end

      it 'gives instructions for getting started' do
        render

        expect(rendered).to include 'Welcome to Spotlight!'
        expect(rendered).to have_link 'Create Exhibit', href: '/exhibits/new'
      end

      it 'has a sidebar with a button to create a new exhibit' do
        render

        expect(rendered).to have_selector 'aside .btn', text: 'Create a new exhibit'
      end
    end
  end
end
