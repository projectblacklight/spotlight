# frozen_string_literal: true

RSpec.describe 'spotlight/searches/_search.html.erb', type: :view do
  let(:search) do
    FactoryBot.build_stubbed(:search, exhibit: FactoryBot.create(:exhibit),
                                      id: 99,
                                      title: 'Title1',
                                      query_params: {
                                        f: {
                                          genre_ssim: ['xyz']
                                        }
                                      })
  end
  let(:thumbnail) { double(id: '7777', iiif_url: '/images/7777/full/400,300/0/default.jpg') }

  before do
    allow(view).to receive_messages(edit_search_path: '/edit', search_path: '/search')
    allow(search).to receive_messages(thumbnail: thumbnail, count: 15, params: {})

    form_for(search, url: '/update') do |f|
      @f = f
    end
  end

  it 'renders a list of pages' do
    # rubocop:disable RSpec/InstanceVariable
    render partial: 'spotlight/searches/search', locals: { f: @f }
    # rubocop:enable RSpec/InstanceVariable
    expect(rendered).to have_css "li[data-id='99']"
    expect(rendered).to have_css '.card-title', text: 'Title1'
    expect(rendered).to have_css 'img[src="/images/7777/full/400,300/0/default.jpg"]'
    expect(rendered).to have_css 'input[type=hidden][data-property=weight]', visible: false
  end
end
