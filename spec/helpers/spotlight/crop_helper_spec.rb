# frozen_string_literal: true

describe Spotlight::CropHelper do
  describe '#form_prefix' do
    let(:form) { double(object_name: 'Spotlight::Exhibit') }

    it 'parameterizes the form object' do
      expect(helper.form_prefix(form)).to eq 'spotlight_exhibit'
    end
  end
end
