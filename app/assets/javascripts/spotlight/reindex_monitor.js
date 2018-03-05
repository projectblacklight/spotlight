Spotlight.onLoad(function() {
  $('[data-behavior="reindex-monitor"]').reindexMonitor();
});

(function($) {
  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer();

  $.fn.reindexMonitor = function() {
    var monitorElements = this;
    var panelContainer;

    $(monitorElements).each(function() {
      panelContainer = $(this);
      exhibitId = panelContainer.data('exhibit-id');
      App.indexing = App.cable.subscriptions.create(
        {
          channel: "Spotlight::ExhibitIndexingChannel",
          id: exhibitId
        },
        {
          connected: function() {
            // FIXME: While we wait for cable subscriptions to always be finalized before sending messages
            setTimeout((function(_this) {
             return function() {
               _this.followCurrentExhibit();
               _this.installPageChangeCallback();
             };
           })(this), 1000);
          },
          received: function(data) {
            if (data.recently_in_progress) {
              updateMonitorPanel(data);
              monitorPanel().show();
            } else {
              monitorPanel().hide();
            }
          },
          followCurrentExhibit: function() {
            this.perform('update', { id: exhibitId });
          },
          installPageChangeCallback: function() {
            if (!this.installedPageChangeCallback) {
              this.installedPageChangeCallback = true;
              return $(document).on('turbolinks:load', function() {
                return App.indexing.followCurrentExhibit();
              });
            }
          }
        }
    )
    });

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
