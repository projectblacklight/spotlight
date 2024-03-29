// translationProgress is a plugin that updates the "3/14" progress
// counters in the tabs of the translation adminstration dashboard.
// This works by counting the number of progress items and translations
// present (indicated by data attributes) in each tab's content
export default class {
  connect() {
    $('[data-behavior="translation-progress"]').each(function(){
      var currentTab = $(this);
      var tabName = $(this).attr('aria-controls');
      var translationFields = $('#' + tabName).find('[data-translation-progress-item="true"]');
      var completedTranslations = $('#' + tabName).find('[data-translation-present="true"]');

      currentTab.find('span').text(completedTranslations.length + '/' + translationFields.length);
    })
  }
}