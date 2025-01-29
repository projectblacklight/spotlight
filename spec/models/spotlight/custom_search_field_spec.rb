# frozen_string_literal: true

RSpec.describe Spotlight::CustomSearchField, type: :model do
  describe '#label' do
    subject { described_class.new configuration: { 'label' => 'the configured label' }, slug: 'foo' }

    describe "when the exhibit doesn't have a config" do
      its(:label) { is_expected.to eq 'the configured label' }
    end

    describe 'when the exhibit has a config' do
      let(:exhibit) { FactoryBot.create(:exhibit) }

      before { subject.exhibit = exhibit }

      describe 'that overrides the label' do
        before do
          exhibit.blacklight_configuration.search_fields['foo'] = { 'label' => 'overridden' }
        end

        its(:label) { is_expected.to eq 'overridden' }
      end

      describe "that doesn't override the label" do
        its(:label) { is_expected.to eq 'the configured label' }
      end
    end
  end

  describe '#label=' do
    subject { described_class.new slug: 'foo' }

    describe "when the exhibit doesn't have a config" do
      before { subject.label = 'the configured label' }

      its(:configuration) { is_expected.to eq('label' => 'the configured label') }
    end

    describe 'when the exhibit has a config' do
      let(:exhibit) { FactoryBot.create(:exhibit) }

      before { subject.exhibit = exhibit }

      describe 'that overrides the label' do
        before do
          exhibit.blacklight_configuration.search_fields['foo'] = { 'label' => 'overridden' }
          subject.label = 'edited'
        end

        it 'has updated the exhibit' do
          expect(subject.exhibit.blacklight_configuration.search_fields['foo']['label']).to eq 'edited'
        end
      end
    end
  end
end
