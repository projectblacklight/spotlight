# frozen_string_literal: true

describe 'spotlight/search_configurations/_facets', type: :view do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:custom_field) { FactoryBot.create(:custom_field, exhibit: exhibit, label: 'Foobar', field_type: 'vocab') }
  let(:config) do
    exhibit.blacklight_configuration
  end
  let(:field_metadata) { double('field_metadata') }
  let(:empty_facet) { { document_count: 0, value_count: 0, terms: [] } }
  let(:nonempty_facet) { { document_count: 1, value_count: 3, terms: %w(a b c) } }
  let(:f) do
    form_helper = nil
    controller.view_context.bootstrap_form_for(config, url: '/update') do |f|
      form_helper = f
    end
    form_helper
  end

  before do
    assign(:blacklight_configuration, config)
    allow(view).to receive_messages(current_exhibit: exhibit,
                                    blacklight_config: config.blacklight_config)
    allow(field_metadata).to receive(:field).with(any_args).and_return(nonempty_facet)
    allow(field_metadata).to receive(:field).with('genre_ssim').and_return(empty_facet)
    allow(field_metadata).to receive(:field).with(custom_field.field).and_return(empty_facet)
    assign(:field_metadata, field_metadata)
    render partial: 'spotlight/search_configurations/facets', locals: { f: f }
  end

  it 'shows the config for the non-empty personal name facet' do
    expect(rendered).to have_content 'Personal Names'
  end

  it 'shows the config for the empty custom facet' do
    expect(rendered).to have_content 'Foobar'
  end

  it 'hides the config for the empty genre facet' do
    expect(rendered).not_to have_content 'Genre'
  end

  describe do
    before do
      original_config = Spotlight::Engine.blacklight_config.deep_dup
      allow(Spotlight::Engine).to receive(:blacklight_config).and_return(original_config)
      original_config.add_facet_field 'some_hidden_field', if: ->(*_args) { false }
    end

    it 'hides the config facets configured not to display' do
      expect(rendered).not_to have_content 'Some hidden field'
    end
  end
end
