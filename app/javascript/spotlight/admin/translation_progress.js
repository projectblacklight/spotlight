// translationProgress is a plugin that updates the "3/14" progress
// counters in the tabs of the translation adminstration dashboard.
// This works by counting the number of progress items and translations
// present (indicated by data attributes) in each tab's content
export default class {
  connect() {
    document.querySelectorAll('[data-behavior="translation-progress"]').forEach(function(tab) {
      var tabName = tab.getAttribute('aria-controls');
      var tabContent = tabName && document.getElementById(tabName);
      if (!tabContent) return;

      var translationFields = tabContent.querySelectorAll('[data-translation-progress-item="true"]');
      var completedTranslations = tabContent.querySelectorAll('[data-translation-present="true"]');

      tab.querySelectorAll('span').forEach(function(span) {
        span.textContent = completedTranslations.length + '/' + translationFields.length;
      });
    });
  }
}
