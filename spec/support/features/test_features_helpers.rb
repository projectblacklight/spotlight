module Spotlight
  module TestFeaturesHelpers
    def fill_in_typeahead_field(opts = {})
      # Poltergeist / Capybara doesn't fire the events typeahead.js
      # is listening for, so we help it out a little:
      page.execute_script <<-EOF
        $("[data-twitter-typeahead]").val("#{opts[:with]}").trigger("input");
        $("[data-twitter-typeahead]").typeahead("open");
        $(".tt-suggestion").click();
      EOF

      find('.tt-suggestion', text: opts[:with], match: :first).click
    end

    def add_widget(type)
      click_add_widget

      # click the item + image widget
      expect(page).to have_css("a[data-type='#{type}']")
      find("a[data-type='#{type}']").click
    end

    def click_add_widget
      # Lame hack to get the sir-trevor Add widget link to work.
      # Not sure if it's the font-icon delayed loading, or something weird w/ the
      # test under javascript where the click handler hasn't been applied when the click happens,
      # but clicking on it an additional time seems to do the trick. 5 times is totally arbitrary,
      # it seems to work after the first attempt.
      5.times do
        break if all('a[data-type]').present?
        find('[data-icon="add"]').click
        sleep(0.1)
      end
    end

    def save_page
      sleep 1
      click_button('Save changes')
      # verify that the page was created
      expect(page).to have_content('page was successfully updated')
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
