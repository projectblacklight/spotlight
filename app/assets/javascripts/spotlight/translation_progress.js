Spotlight.onLoad(function() {
  $('[data-behavior="translation-progress"]').translationProgress();
});

(function($) {
  $.fn.translationProgress = function() {
    var translationTabs = this;
    $(translationTabs).each(function(){
      var currentTab = $(this);
      var tabName = $(this).attr('aria-controls');
      var translationFields = $('#' + tabName).find('[data-translation-progress-item="true"]');
      var completedTranslations = $('#' + tabName).find('[data-translation-present="true"]');

      currentTab.find('span').text(completedTranslations.length + '/' + translationFields.length);
    });

    return this;
  };
})(jQuery);
