describe 'spotlight/searches/_search.html.erb', type: :view do
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
    allow(view).to receive(:edit_search_path).and_return('/edit')
    allow(view).to receive(:search_path).and_return('/search')
    allow(search).to receive(:thumbnail).and_return(thumbnail)
    allow(search).to receive(:count).and_return(15)
    allow(search).to receive(:params).and_return({})

    form_for(search, url: '/update') do |f|
      @f = f
    end
  end

  it 'renders a list of pages' do
    # rubocop:disable RSpec/InstanceVariable
    render partial: 'spotlight/searches/search', locals: { f: @f }
    # rubocop:enable RSpec/InstanceVariable
    expect(rendered).to have_selector "li[data-id='99']"
    expect(rendered).to have_selector '.panel-heading .main .title', text: 'Title1'
    expect(rendered).to have_selector 'img[src="/images/7777/full/400,300/0/default.jpg"]'
    expect(rendered).to have_selector 'input[type=hidden][data-property=weight]', visible: false
  end
end
