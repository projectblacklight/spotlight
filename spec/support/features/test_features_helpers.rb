# frozen_string_literal: true

module Spotlight
  module TestFeaturesHelpers
    def fill_in_typeahead_field(opts = {})
      type = opts[:type] || 'default'

      # This first click here is not needed in terms of user interaction, but it
      # makes the test more reliable. Otherwise the fill_in can happen prior
      # to auto-complete-element being fully initialized and the test will fail.
      find("auto-complete [data-#{type}-typeahead]").click
      find("auto-complete[open] [data-#{type}-typeahead]").fill_in(with: opts[:with])
      find('auto-complete[open] [role="option"]', text: opts[:with], match: :first).click
    end

    # just like #fill_in_typeahead_field, but wait for the
    # form fields to show up on the page too
    def fill_in_solr_document_block_typeahead_field(opts)
      fill_in_typeahead_field(opts)
      expect(page).to have_css('li[data-resource-id="' + opts[:with] + '"]')
    end

    def add_widget(type)
      click_add_widget

      # click the item + image widget
      expect(page).to have_css("button[data-type='#{type}']")
      find("button[data-type='#{type}']").click
    end

    def click_add_widget
      if all('.st-block-replacer').blank?
        expect(page).to have_css('.st-block-addition')
        first('.st-block-addition').click
      end
      expect(page).to have_css('.st-block-replacer')
      first('.st-block-replacer').click
    end

    def save_page_changes
      page.execute_script <<-EOF
        SirTrevor.getInstance().onFormSubmit();
      EOF
      click_button('Save changes')
      # verify that the page was created
      expect(page).to have_no_selector('.alert-danger')
      expect(page).to have_selector('.alert-info', text: 'page was successfully updated')
    end

    RSpec::Matchers.define :have_breadcrumbs do |*expected|
      match do |actual|
        errors = []
        errors << 'Unable to find breadcrumbs' unless actual.has_css? '.breadcrumb'

        breadcrumbs = expected.dup

        actual.within('.breadcrumb') do
          last = breadcrumbs.pop
          breadcrumbs.each do |e|
            errors << "Unable to find breadcrumb #{e}" unless actual.has_link? e
          end

          errors << "Unable to find breadcrumb #{last}" unless actual.has_content? last
          errors << "Expected #{last} not to be a link" if actual.has_link? last
        end

        errors.empty?
      end

      failure_message do |actual|
        "expected that #{actual.all('.breadcrumb li').map(&:text).join(' / ')} would include #{expected.join(' / ')}"
      end
    end
  end
end
