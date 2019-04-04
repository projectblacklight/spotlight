# frozen_string_literal: true

describe 'shared/_footer', type: :view do
  let(:current_exhibit) { double(title: 'Some title', subtitle: 'Subtitle') }

  before do
    allow(view).to receive_messages(current_exhibit: current_exhibit)
  end

  it 'includes analytics reporting' do
    stub_template 'shared/_analytics.html.erb' => 'analytics'
    render
    expect(rendered).to have_content 'analytics'
  end
end
