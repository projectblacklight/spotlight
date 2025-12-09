# frozen_string_literal: true

module Spotlight
  module TestFeaturesHelpers
    def fill_in_typeahead_field(opts = {})
      type = opts[:type] || 'default'

      # Role=combobox indicates that the auto-complete is initialized
      find("auto-complete [data-#{type}-typeahead][role='combobox']").fill_in(with: opts[:with])
      # Wait for the autocomplete to show both 'open' and 'aria-expanded="true"' or the results might be stale
      expect(page).to have_css("auto-complete[open] [data-#{type}-typeahead][role='combobox'][aria-expanded='true']")
      first('auto-complete[open] [role="option"]', text: opts[:with]).click
    end

    # just like #fill_in_typeahead_field, but wait for the
    # form fields/thumbnail preview to show up on the page too
    def fill_in_solr_document_block_typeahead_field(opts)
      wait_for_sir_trevor
      fill_in_typeahead_field(opts)
      expect(page).to have_css('input[value="' + opts[:with] + '"]', visible: false)
      expect(page).to have_css('li[data-resource-id="' + opts[:with] + '"] .img-thumbnail[src^="http"]')
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

    def wait_for_sir_trevor
      expect(page).to have_selector('.st-blocks.st-ready')
    end

    def save_page_changes
      click_button('Save changes')
      # verify that the page was created.
      expect(page).to have_selector('.alert-info', text: 'was successfully updated')
      expect(page).to have_no_selector('.alert-danger')
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
