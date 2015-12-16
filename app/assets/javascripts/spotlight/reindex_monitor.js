Spotlight.onLoad(function() {
  $('[data-behavior="reindex-monitor"]').reindexMonitor();
});

(function($) {
  $.fn.reindexMonitor = function() {
    var monitorElements = this;
    var defaultRefreshRate = 3000;
    var panelContainer;

    $(monitorElements).each(function() {
      panelContainer = $(this);
      var monitorUrl = panelContainer.data('monitorUrl');
      var refreshRate = panelContainer.data('refreshRate') || defaultRefreshRate;
      setInterval(function() {
        checkMonitorUrl(monitorUrl);
      }, refreshRate);
    });

    function checkMonitorUrl(url) {
      $.ajax(url).success(success).fail(fail);
    }

    function success(data) {
      if (data.in_progress) {
        monitorPanel().show();
        updateMonitorPanel(data);
      } else {
        monitorPanel().hide();
      }
    }

    function fail() { monitorPanel().hide(); }

    function updateMonitorPanel(data) {
      panelStartDate().text(data.started);
      panelCurrentDate().text(data.updated_at);
      panelCompleted().text(data.completed);
      updatePanelTotals(data);
      updatePanelErrorMessage(data);
      updateProgressBar(data);
    }

    function updateProgressBar(data) {
      var percentage = calculatePercentage(data);
      progressBar()
        .attr('aria-valuemax', data.total)
        .attr('aria-valuenow', percentage)
        .css('width', percentage + '%')
        .text(percentage + '%');
    }

    function updatePanelErrorMessage(data) {
      // We currently do not store this state,
      // but with this code we can in the future.
      if ( data.errored ) {
        panelErrorMessage().show();
      } else {
        panelErrorMessage().hide();
      }
    }

    function updatePanelTotals(data) {
      panelTotals().each(function() {
        $(this).text(data.total);
      });
    }

    function calculatePercentage(data) {
      return Math.floor((data.completed / data.total) * 100);
    }

    function monitorPanel() {
      return panelContainer.find('.index-status');
    }

    function panelStartDate() {
      return monitorPanel()
               .find('[data-behavior="monitor-start"]')
               .find('[data-behavior="date"]');
    }

    function panelCurrentDate() {
      return monitorPanel()
               .find('[data-behavior="monitor-current"]')
               .find('[data-behavior="date"]');
    }

    function panelTotals() {
      return monitorPanel().find('[data-behavior="total"]');
    }

    function panelCompleted() {
      return monitorPanel()
               .find('[data-behavior="monitor-current"]')
               .find('[data-behavior="completed"]');
    }

    function progressBar() {
      return monitorPanel().find('.progress-bar');
    }

    function panelErrorMessage() {
      return monitorPanel().find('[data-behavior="monitor-error"]');
    }

    return this;
  };
})(jQuery);
