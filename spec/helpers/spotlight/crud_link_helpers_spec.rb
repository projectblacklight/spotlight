require 'spec_helper'

module Spotlight
  describe CrudLinkHelpers do
    let(:some_model) { Spotlight::FeaturePage.create! exhibit: Spotlight::Exhibit.default }
    describe "#cancel_link" do

      it "should be a model-specific cancel link" do
        helper.should_receive(:action_default_value).with(:my_model, :cancel).and_return "Cancel"
        expect(helper.cancel_link(:my_model, "#")).to have_link "Cancel", href: "#"
      end
    end

    describe "#view_link" do
      before do
        helper.stub action_default_value: "View"
      end

      it "should be a model-specific view link" do
        helper.should_receive(:action_default_value).with(some_model, :view).and_return "View"
        expect(helper.view_link(some_model)).to have_link "View", href: spotlight.feature_page_path(some_model)
      end

      it "should accept an explicit link" do
        expect(helper.view_link(some_model, '#')).to have_link "View", href: "#"
      end

      it "should accept link_to options" do
        expect(helper.view_link(some_model, '#', class: 'btn')).to have_selector 'a.btn'
      end
    end

    describe "#exhibit_create_link" do
      let(:current_exhibit) { Spotlight::Exhibit.default }
      let(:some_model) { Spotlight::FeaturePage.new }
      before do
        helper.stub(current_exhibit: current_exhibit)
        helper.stub action_default_value: "Create"
      end

      it "should be a model-specific view link" do
        helper.should_receive(:action_default_value).with(some_model).and_return "Create"
        expect(helper.exhibit_create_link(some_model)).to have_link "Create", href: spotlight.new_exhibit_feature_page_path(current_exhibit)
      end

      it "should accept an explicit link" do
        expect(helper.exhibit_create_link(some_model, '#')).to have_link "Create", href: "#"
      end

      it "should accept link_to options" do
        expect(helper.exhibit_create_link(some_model, '#', class: 'btn')).to have_selector 'a.btn'
      end
    end
    describe "#edit_link" do
      before do
        helper.stub action_default_value: "Edit"
      end

      it "should be a model-specific view link" do
        helper.should_receive(:action_default_value).with(some_model).and_return "Edit"
        expect(helper.edit_link(some_model)).to have_link "Edit", href: spotlight.edit_feature_page_path(some_model)
      end

      it "should accept an explicit link" do
        expect(helper.edit_link(some_model, '#')).to have_link "Edit", href: "#"
      end

      it "should accept link_to options" do
        expect(helper.edit_link(some_model, '#', class: 'btn')).to have_selector 'a.btn'
      end
    end

    describe "#delete_link" do
      before do
        helper.stub action_default_value: "Delete"
      end

      it "should be a model-specific view link" do
        helper.should_receive(:action_default_value).with(some_model, :destroy).and_return "Delete"
        expect(helper.delete_link(some_model)).to have_link "Delete", href: spotlight.feature_page_path(some_model)
      end

      it "should accept an explicit link" do
        expect(helper.delete_link(some_model, '#')).to have_link "Delete", href: "#"
      end

      it "should accept link_to options" do
        expect(helper.delete_link(some_model, '#', class: 'btn')).to have_selector 'a.btn'
      end
    end

    describe "#action_label" do
      it "should return the label for an action on a model" do
        some_model = double
        helper.should_receive(:action_default_value).with(some_model, :action).and_return "xyz"
        expect(helper.action_label(some_model, :action)).to eq "xyz"
      end
    end

    describe "#action_default_value" do
      it "should attempt i18n lookups for models" do
        I18n.should_receive(:t).with(:'helpers.action.spotlight/feature_page.edit', model: some_model.class.model_name.human, default: [:'helpers.action.edit', 'Edit Feature page'])
        expect(helper.send(:action_default_value, some_model))
      end

      it "should attempt i18n lookups for unpersisted models" do
        some_model = Spotlight::FeaturePage.new
        I18n.should_receive(:t).with(:'helpers.action.spotlight/feature_page.create', model: some_model.class.model_name.human, default: [:'helpers.action.create', 'Create Feature page'])
        expect(helper.send(:action_default_value, some_model))
      end

      it "should attempt i18n lookups for models with an explicit action" do
        I18n.should_receive(:t).with(:'helpers.action.spotlight/feature_page.custom_action', model: some_model.class.model_name.human, default: [:'helpers.action.custom_action', 'Custom action Feature page'])
        expect(helper.send(:action_default_value, some_model, :custom_action))
      end

      it "should attempt i18n lookups for symbols" do
        I18n.should_receive(:t).with(:'helpers.action.my_thing.custom_action', model: :my_thing, default: [:'helpers.action.custom_action', 'Custom action my_thing'])
        expect(helper.send(:action_default_value, :my_thing, :custom_action))

      end
    end
  end
end