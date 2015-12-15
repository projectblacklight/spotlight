require 'spec_helper'

describe Spotlight::CustomField, type: :model do
  describe '#label' do
    subject { described_class.new configuration: { 'label' => 'the configured label' }, field: 'foo_tesim' }
    describe "when the exhibit doesn't have a config" do
      its(:label) { should eq 'the configured label' }
    end

    describe 'when the exhibit has a config' do
      let(:exhibit) { FactoryGirl.create(:exhibit) }
      before { subject.exhibit = exhibit }
      describe 'that overrides the label' do
        before do
          exhibit.blacklight_configuration.index_fields['foo_tesim'] = { 'label' => 'overridden' }
        end
        its(:label) { should eq 'overridden' }
      end
      describe "that doesn't override the label" do
        its(:label) { should eq 'the configured label' }
      end
    end
  end

  describe '#label=' do
    subject { described_class.new field: 'foo_tesim' }
    describe "when the exhibit doesn't have a config" do
      before { subject.label = 'the configured label' }
      its(:configuration) { should eq('label' => 'the configured label') }
    end

    describe 'when the exhibit has a config' do
      let(:exhibit) { FactoryGirl.create(:exhibit) }
      before { subject.exhibit = exhibit }
      describe 'that overrides the label' do
        before do
          exhibit.blacklight_configuration.index_fields['foo_tesim'] = { 'label' => 'overridden' }
          subject.label = 'edited'
        end
        it 'has updated the exhibit' do
          expect(subject.exhibit.blacklight_configuration.index_fields['foo_tesim']['label']).to eq 'edited'
        end
      end
    end
  end

  describe '#field' do
    let(:exhibit) { double(to_param: 'a', solr_document_sidecars: Spotlight::SolrDocumentSidecar.none) }

    before do
      subject.label = 'xyz'
      subject.save

      allow(Spotlight::RenameSidecarFieldJob).to receive(:perform_later)
    end

    it 'is auto-generated from the field label' do
      expect(subject.field).to start_with 'xyz'
    end

    it 'ends in the text suffix if it is a text field' do
      subject.field_type = 'text'
      subject.save
      expect(subject.field).to end_with Spotlight::Engine.config.solr_fields.text_suffix
    end

    it 'ends in a string suffix if it is a vocab field' do
      subject.field_type = 'vocab'
      subject.save
      expect(subject.field).to end_with Spotlight::Engine.config.solr_fields.string_suffix
    end
  end

  describe '#solr_field' do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    let(:custom_field) do
      described_class.create(exhibit: exhibit, configuration: { 'label' => 'xyz' })
    end

    subject { custom_field.solr_field }

    it 'is auto-generated from the field label' do
      expect(subject).to eq "exhibit_#{exhibit.to_param}_xyz_tesim"
    end

    context 'with a solr field prefix configured' do
      before do
        allow(Spotlight::Engine.config.solr_fields).to receive(:prefix).and_return 'prefix_'
      end

      it 'uses the solr field prefix' do
        expect(subject).to eq "prefix_exhibit_#{exhibit.to_param}_xyz_tesim"
      end
    end

    context 'for a legacy solr field name' do
      before do
        custom_field.field = "exhibit_#{exhibit.to_param}_xyz_tesim"
      end

      it 'returns the original field name' do
        expect(subject).to eq "exhibit_#{exhibit.to_param}_xyz_tesim"
      end
    end
  end

  describe '#configured_to_display?' do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    before do
      exhibit.blacklight_configuration.blacklight_config.view = { view_name: {} }
      subject.exhibit = exhibit
      subject.label = 'Label'
      subject.field = 'foo_tesim'
    end
    it 'is truthy when a view has been configured true' do
      exhibit.blacklight_configuration.blacklight_config.index_fields['foo_tesim'] =
        Blacklight::Configuration::IndexField.new(label: 'Label', enabled: true, view_name: true)
      subject.save

      expect(subject).to be_configured_to_display
    end
    it 'is truthey for show views when enabled' do
      exhibit.blacklight_configuration.blacklight_config.index_fields['foo_tesim'] =
        Blacklight::Configuration::IndexField.new(label: 'Label', enabled: true, show: true)
      subject.save

      expect(subject).to be_configured_to_display
    end
    it 'is falsey when a few has not been configured true' do
      exhibit.blacklight_configuration.blacklight_config.index_fields['foo_tesim'] =
        Blacklight::Configuration::IndexField.new(label: 'Label', enabled: true, view_name: false)
      subject.save

      expect(subject).to_not be_configured_to_display
    end
    it 'is falsey when the field is not enabled' do
      exhibit.blacklight_configuration.index_fields['foo_tesim'] = { 'label' => 'overridden', enabled: false, view_name: false }
      subject.save

      expect(subject).to_not be_configured_to_display
    end
  end

  describe 'changing the field type' do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    before do
      subject.label = 'xyz'
      subject.exhibit = exhibit
      subject.save!
    end

    it 'changes the field name for the field' do
      expect(subject.field).to end_with 'tesim'
      subject.field_type = 'vocab'
      subject.save
      expect(subject.field).to end_with 'ssim'
    end

    it 'copies index field configuration to the new field name' do
      subject.exhibit.blacklight_configuration.index_fields_will_change!
      subject.exhibit.blacklight_configuration.index_fields[subject.field] = { value: true }
      subject.exhibit.blacklight_configuration.save
      expect(subject.exhibit.blacklight_configuration.index_fields).to have_key subject.field

      subject.field_type = 'vocab'
      subject.save
      expect(subject.exhibit.blacklight_configuration.index_fields).to have_key subject.field
      expect(subject.exhibit.blacklight_configuration.index_fields[subject.field]).to include value: true
    end

    it 'queues a job to reindex any documents with data in the old field' do
      expect(Spotlight::RenameSidecarFieldJob).to receive(:perform_later).with(exhibit, subject.field, subject.field.sub('tesim', 'ssim'))
      subject.field_type = 'vocab'
      subject.save
    end
  end
end
