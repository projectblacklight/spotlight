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
end
