require 'spec_helper'

module Spotlight
  describe CrudLinkHelpers, type: :helper do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    let(:some_model) { Spotlight::FeaturePage.create! exhibit: exhibit }
    describe '#cancel_link' do
      it 'is a model-specific cancel link' do
        expect(helper).to receive(:action_default_value).with(:my_model, :cancel).and_return 'Cancel'
        expect(helper.cancel_link(:my_model, '#')).to have_link 'Cancel', href: '#'
      end
    end

    describe '#exhibit_view_link' do
      before do
        allow(helper).to receive_messages action_default_value: 'View'
      end

      it 'is a model-specific view link' do
        expect(helper).to receive(:action_default_value).with(some_model, :view).and_return 'View'
        expect(helper.exhibit_view_link(some_model)).to have_link 'View', href: spotlight.exhibit_feature_page_path(some_model.exhibit, some_model)
      end

      it 'accepts an explicit link' do
        expect(helper.exhibit_view_link(some_model, '#')).to have_link 'View', href: '#'
      end

      it 'accepts link_to options' do
        expect(helper.exhibit_view_link(some_model, '#', class: 'btn')).to have_selector 'a.btn'
      end
    end

    describe '#exhibit_create_link' do
      let(:some_model) { Spotlight::FeaturePage.new }
      before do
        allow(helper).to receive_messages(current_exhibit: exhibit)
        allow(helper).to receive_messages action_default_value: 'Create'
      end

      it 'is a model-specific view link' do
        expect(helper).to receive(:action_default_value).with(some_model).and_return 'Create'
        expect(helper.exhibit_create_link(some_model)).to have_link 'Create', href: spotlight.new_exhibit_feature_page_path(exhibit)
      end

      it 'accepts an explicit link' do
        expect(helper.exhibit_create_link(some_model, '#')).to have_link 'Create', href: '#'
      end

      it 'accepts link_to options' do
        expect(helper.exhibit_create_link(some_model, '#', class: 'btn')).to have_selector 'a.btn'
      end
    end

    describe '#exhibit_edit_link' do
      let(:some_model) { Spotlight::FeaturePage.create! exhibit: exhibit }
      before do
        allow(helper).to receive_messages(current_exhibit: exhibit)
        allow(helper).to receive_messages action_default_value: 'Edit'
      end

      it 'is a model-specific edit link' do
        expect(helper).to receive(:action_default_value).with(some_model).and_return 'Edit'
        expect(helper.exhibit_edit_link(some_model)).to have_link 'Edit', href: spotlight.edit_exhibit_feature_page_path(exhibit, some_model)
      end

      it 'accepts an explicit link' do
        expect(helper.exhibit_edit_link(some_model, '#')).to have_link 'Edit', href: '#'
      end

      it 'accepts link_to options' do
        expect(helper.exhibit_edit_link(some_model, '#', class: 'btn')).to have_selector 'a.btn'
      end
    end

    describe '#exhibit_delete_link' do
      before do
        allow(helper).to receive_messages action_default_value: 'Delete'
      end

      it 'is a model-specific view link' do
        expect(helper).to receive(:action_default_value).with(some_model, :destroy).and_return 'Delete'
        expect(helper.exhibit_delete_link(some_model)).to have_link 'Delete', href: spotlight.exhibit_feature_page_path(some_model.exhibit, some_model)
      end

      it 'accepts an explicit link' do
        expect(helper.exhibit_delete_link(some_model, '#')).to have_link 'Delete', href: '#'
      end

      it 'accepts link_to options' do
        expect(helper.exhibit_delete_link(some_model, '#', class: 'btn')).to have_selector 'a.btn'
      end
    end

    describe '#action_label' do
      it 'returns the label for an action on a model' do
        some_model = double
        expect(helper).to receive(:action_default_value).with(some_model, :action).and_return 'xyz'
        expect(helper.action_label(some_model, :action)).to eq 'xyz'
      end
    end

    describe '#action_default_value' do
      it 'attempts i18n lookups for models' do
        expect(I18n).to receive(:t).with(:'helpers.action.spotlight/feature_page.edit',
                                         model: some_model.class.model_name.human,
                                         default: [:'helpers.action.edit', 'Edit Feature page'])
        expect(helper.send(:action_default_value, some_model))
      end

      it 'attempts i18n lookups for unpersisted models' do
        some_model = Spotlight::FeaturePage.new
        expect(I18n).to receive(:t).with(:'helpers.action.spotlight/feature_page.create',
                                         model: some_model.class.model_name.human,
                                         default: [:'helpers.action.create', 'Create Feature page'])
        expect(helper.send(:action_default_value, some_model))
      end

      it 'attempts i18n lookups for models with an explicit action' do
        expect(I18n).to receive(:t).with(:'helpers.action.spotlight/feature_page.custom_action',
                                         model: some_model.class.model_name.human,
                                         default: [:'helpers.action.custom_action', 'Custom action Feature page'])
        expect(helper.send(:action_default_value, some_model, :custom_action))
      end

      it 'attempts i18n lookups for symbols' do
        expect(I18n).to receive(:t).with(:'helpers.action.my_thing.custom_action',
                                         model: :my_thing,
                                         default: [:'helpers.action.custom_action', 'Custom action my_thing'])
        expect(helper.send(:action_default_value, :my_thing, :custom_action))
      end
    end
  end
end
