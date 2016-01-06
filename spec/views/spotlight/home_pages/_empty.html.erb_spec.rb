require 'spec_helper'

describe 'spotlight/home_pages/_empty.html.erb', type: :view do
  describe 'resource providers' do
    before do
      allow(view).to receive_messages(current_exhibit: FactoryGirl.create(:exhibit),
                                      can?: true,
                                      edit_exhibit_path: '/',
                                      edit_exhibit_appearance_path: '/',
                                      exhibit_roles_path: '/',
                                      admin_exhibit_catalog_index_path: '/',
                                      edit_exhibit_metadata_configuration_path: '/',
                                      edit_exhibit_search_configuration_path: '/')
    end
    it 'has a list item with a link to add items when there are resource partials configured' do
      allow(Spotlight::Engine.config).to receive_messages(resource_partials: [true])
      render
      expect(rendered).to have_css('li a', text: 'Curation > Items')
    end
    it 'does not have a list item with a link to add items when there are no resource partials configured' do
      allow(Spotlight::Engine.config).to receive_messages(resource_partials: [])
      render
      expect(rendered).to_not have_css('li a', text: 'Curation > Items')
    end
  end
end
