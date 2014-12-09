module Spotlight::TestFeaturesHelpers
  def fill_in_typeahead_field selector, opts = {}
    # Poltergeist / Capybara doesn't fire the events typeahead.js
    # is listening for, so we help it out a little:
    page.execute_script <<-EOF
      $("input[name='#{selector}']").val("#{opts[:with]}").trigger("input");
      $("input[name='#{selector}']").typeahead("open");
      $(".tt-suggestion").click();
    EOF

    find('.tt-suggestion').click
  end

  RSpec::Matchers.define :have_breadcrumbs do |*expected|
    match do |actual|
      errors = []
      errors << "Unable to find breadcrumbs" unless actual.has_css? ".breadcrumb"

      breadcrumbs = expected.dup

      actual.within(".breadcrumb") do
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
      "expected that #{actual.all(".breadcrumb li").map { |x| x.text }.join(" / ")} would include #{expected.join(" / ")}"
    end
  end
end
