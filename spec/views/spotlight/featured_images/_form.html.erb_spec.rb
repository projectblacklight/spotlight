# frozen_string_literal: true

describe 'spotlight/featured_images/_form', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit, :with_thumbnail) }
  let(:builder) { ActionView::Helpers::FormBuilder.new 'z', exhibit.thumbnail, view, {} }

  before do
    assign(:exhibit, exhibit)
    allow(builder).to receive_messages(file_field_without_bootstrap: nil)
    allow(view).to receive_messages(exhibit_thumbnails_path: nil)
    I18n.backend.backends.second.store_translations(
      :en,
      spotlight: {
        featured_images: {
          form: {
            source: {
              remote: {
                help: 'Help!'
              }
            }
          }
        }
      }
    )
  end

  it 'has help block' do
    render partial: 'spotlight/featured_images/form',
           locals: { f: builder, initial_crop_selection: [], crop_type: :thumbnail }
    expect(rendered).to have_css '.help-block', text: 'Help!'
  end
end
