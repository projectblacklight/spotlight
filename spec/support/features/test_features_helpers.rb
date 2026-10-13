# frozen_string_literal: true

module Spotlight
  module TestFeaturesHelpers
    def fill_in_typeahead_field(opts = {})
      type = opts[:type] || 'default'

      # Role=combobox indicates that the auto-complete is initialized
      find("auto-complete [data-#{type}-typeahead][role='combobox']").fill_in(with: opts[:with])
      # Wait for the autocomplete to show both 'open' and 'aria-expanded="true"' or the results might be stale
      expect(page).to have_css("auto-complete[open] [data-#{type}-typeahead][role='combobox'][aria-expanded='true']")
      # The auto-complete element fires one fetch on focus and another debounced fetch on input. In CI
      # they can land out of order, and whichever returns second replaces the results <ul> wholesale
      # turning any <li> we just located into a stale reference. Retry find+click as one unit so each
      # attempt resolves against the latest DOM.
      page.document.synchronize(
        Capybara.default_max_wait_time,
        errors: [Selenium::WebDriver::Error::StaleElementReferenceError, Capybara::ElementNotFound]
      ) do
        first('auto-complete[open] [role="option"]', text: opts[:with], minimum: 1).click
      end
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
      expect(page).to have_css('.st-blocks.st-ready')
    end

    # Run the block (e.g. submitting a form) and wait for Turbo to render the
    # new page, so later steps don't act on the old one. Waiting for something
    # like an enabled submit button isn't enough: Turbo disables the submitter
    # only while the request is in flight, so the old page can satisfy the
    # check before the submission starts and again after it finishes. Turbo
    # replaces the body on every render, so wait for the marked body to go
    # away.
    def expect_new_page
      page.execute_script("document.body.setAttribute('data-previous-page', '')")
      yield
      expect(page).to have_no_css('body[data-previous-page]')
      expect(page).to have_no_css('html[aria-busy]')
    end

    # Headless Chrome blocks real clipboard access, so replace writeText
    # with a shim that stashes its argument on window for assertion.
    def stub_clipboard
      page.execute_script(<<~JS)
        window.__copied = null
        navigator.clipboard.writeText = (text) => { window.__copied = text; return Promise.resolve() }
      JS
    end

    def save_page_changes
      click_button('Save changes')
      # verify that the page was created.
      expect(page).to have_css('.alert-info', text: 'was successfully updated')
      expect(page).to have_no_selector('.alert-danger')
    end

    # Capybara's HTML5 drag emulation sends the drag events to a given element. This drags
    # to a point instead, so the test covers what is under the pointer.
    def drag_horizontally(handle, by:)
      # elementFromPoint returns null for a point outside the viewport
      page.scroll_to(handle, align: :center)
      page.driver.browser.action.click_and_hold(handle.native).perform
      error = page.evaluate_async_script(DRAG_HORIZONTALLY_SCRIPT, handle, by)
      page.driver.browser.action.release.perform
      raise error if error
    end

    DRAG_HORIZONTALLY_SCRIPT = <<~JS
      const [handle, offset, done] = arguments
      const item = handle.closest('.dd-item')
      const tick = () => new Promise((resolve) => setTimeout(resolve, 50))
      const opts = { bubbles: true, cancelable: true, dataTransfer: new DataTransfer() }

      item.dispatchEvent(new DragEvent('dragstart', opts))
      tick().then(() => {
        const rect = handle.getBoundingClientRect()
        const point = { clientX: rect.left + rect.width / 2 + offset, clientY: rect.top + rect.height / 2 }
        const target = document.elementFromPoint(point.clientX, point.clientY)
        target.dispatchEvent(new DragEvent('dragover', { ...opts, ...point }))
        return tick().then(() => {
          target.dispatchEvent(new DragEvent('drop', { ...opts, ...point }))
          item.dispatchEvent(new DragEvent('dragend', { ...opts, ...point }))
          done()
        })
      }).catch((error) => done(String(error)))
    JS

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
