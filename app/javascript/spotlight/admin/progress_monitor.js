import consumer from "../channels/consumer"

export default class {
  connect() {
    var monitorElements = $('[data-behavior="progress-panel"]');
    var panelContainer;
    var pollers = [];

    $(monitorElements).each(function() {
      panelContainer = $(this);
      panelContainer.hide();
      var monitorUrl = panelContainer.data('monitorUrl');

      if (monitorUrl){
        var refreshRate = panelContainer.data('refreshRate') || 3000;
        pollers.push(
          setInterval(function() {
            checkMonitorUrl(monitorUrl);
          }, refreshRate)
        );
      } else {
        consumer.subscriptions.create({ channel: "ProgressChannel"}, {
          received(data) {
            if (data.exhibit_id != panelContainer.data('exhibit-id')) return;
            updateMonitorPanel(data);
          }
        });
      }
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
      panelCompletedDate().text(data.updated_at);
      panelCurrent().text(data.completed);
      setPanelCompleted(data.finished);
      updatePanelTotals(data);
      updatePanelErrorMessage(data);
      updateProgressBar(data);

      panelContainer.show();
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

    function panelCompletedDate() {
      return monitorPanel()
               .find('[data-behavior="monitor-completed"]')
               .find('[data-behavior="date"]');
    }

    function panelTotals() {
      return monitorPanel().find('[data-behavior="total"]');
    }

    function panelCurrent() {
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

    function setPanelCompleted(finished) {
      var panel = monitorPanel().find('[data-behavior="monitor-completed"]');

      if (finished) {
        panel.show();
      } else {
        panel.hide();
      }
    }

    return this;
  }
}
