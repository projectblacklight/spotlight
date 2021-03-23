Spotlight.onLoad(function() {
  $('[data-behavior="progress-panel"]').progressMonitor();
});

(function($) {
  $.fn.progressMonitor = function() {
    var monitorElements = this;
    var defaultRefreshRate = 3000;
    var panelContainer;
    var pollers = [];

    $(monitorElements).each(function() {
      panelContainer = $(this);
      var monitorUrl = panelContainer.data('monitorUrl');
      var refreshRate = panelContainer.data('refreshRate') || defaultRefreshRate;
      pollers.push(
        setInterval(function() {
          checkMonitorUrl(monitorUrl);
        }, refreshRate)
      );
    });

    // Clear the intervals on turbolink:click event (e.g. when the user navigates away from the page)
    $(document).on('turbolinks:click', function() {
      if (pollers.length > 0) {
        $.each(pollers, function() {
          clearInterval(this);
        });
        pollers = [];
      }
    });

    function checkMonitorUrl(url) {
      $.ajax(url).done(success).fail(fail);
    }

    function success(data) {
      if (data.recently_in_progress) {
        updateMonitorPanel(data);
        monitorPanel().show();
      } else {
        monitorPanel().hide();
      }
    }

    function fail() { monitorPanel().hide(); }

    function updateMonitorPanel(data) {
      panelStartDate().text(data.started_at);
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

      if (data.finished) {
        progressBar().removeClass('active').removeClass('progress-bar-striped');
      }
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
      if (data.total == 0) return 0;
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
