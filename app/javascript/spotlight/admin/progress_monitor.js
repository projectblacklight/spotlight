export default class {
  connect() {
    var monitorElements = document.querySelectorAll('[data-behavior="progress-panel"]')
    var defaultRefreshRate = 3000
    var panelContainer
    var pollers = []

    monitorElements.forEach(function (el) {
      panelContainer = el
      panelContainer.style.display = "none"
      var monitorUrl = panelContainer.dataset.monitorUrl
      var refreshRate = panelContainer.dataset.refreshRate || defaultRefreshRate
      pollers.push(
        setInterval(function () {
          checkMonitorUrl(monitorUrl)
        }, refreshRate)
      )
    })

    // Clear the intervals on turbolink:click event (e.g. when the user navigates away from the page)
    document.addEventListener("turbolinks:click", function () {
      if (pollers.length > 0) {
        pollers.forEach(function (poller) {
          clearInterval(poller)
        })
        pollers = []
      }
    })

    function checkMonitorUrl(url) {
      fetch(url)
        .then(function (response) {
          if (!response.ok) {
            throw new Error("Network response was not ok")
          }
          return response.json()
        })
        .then(success)
        .catch(fail)
    }

    function success(data) {
      var panel = monitorPanel()
      if (!panel) return
      if (data.recently_in_progress) {
        updateMonitorPanel(data)
        panel.style.display = ""
      } else {
        panel.style.display = "none"
      }
    }

    function fail() {
      var panel = monitorPanel()
      if (panel) panel.style.display = "none"
    }

    function updateMonitorPanel(data) {
      setText(panelStartDate(), data.started_at)
      setText(panelCurrentDate(), data.updated_at)
      setText(panelCompletedDate(), data.updated_at)
      setText(panelCurrent(), data.completed)
      setPanelCompleted(data.finished)
      updatePanelTotals(data)
      updatePanelErrorMessage(data)
      updateProgressBar(data)

      panelContainer.style.display = ""
    }

    function setText(el, value) {
      if (el) el.textContent = value
    }

    function updateProgressBar(data) {
      var percentage = calculatePercentage(data)
      var bar = progressBar()
      if (!bar) return
      bar.setAttribute("aria-valuemax", data.total)
      bar.setAttribute("aria-valuenow", percentage)
      bar.style.width = percentage + "%"
      bar.textContent = percentage + "%"

      if (data.finished) {
        bar.classList.remove("active")
        bar.classList.remove("progress-bar-striped")
      }
    }

    function updatePanelErrorMessage(data) {
      // We currently do not store this state,
      // but with this code we can in the future.
      var message = panelErrorMessage()
      if (!message) return
      message.style.display = data.errored ? "" : "none"
    }

    function updatePanelTotals(data) {
      panelTotals().forEach(function (el) {
        el.textContent = data.total
      })
    }

    function calculatePercentage(data) {
      if (data.total == 0) return 0
      return Math.floor((data.completed / data.total) * 100)
    }

    function monitorPanel() {
      return panelContainer.querySelector(".index-status")
    }

    function panelStartDate() {
      return monitorPanel()
        ?.querySelector('[data-behavior="monitor-start"]')
        ?.querySelector('[data-behavior="date"]')
    }

    function panelCurrentDate() {
      return monitorPanel()
        ?.querySelector('[data-behavior="monitor-current"]')
        ?.querySelector('[data-behavior="date"]')
    }

    function panelCompletedDate() {
      return monitorPanel()
        ?.querySelector('[data-behavior="monitor-completed"]')
        ?.querySelector('[data-behavior="date"]')
    }

    function panelTotals() {
      return monitorPanel().querySelectorAll('[data-behavior="total"]')
    }

    function panelCurrent() {
      return monitorPanel()
        ?.querySelector('[data-behavior="monitor-current"]')
        ?.querySelector('[data-behavior="completed"]')
    }

    function progressBar() {
      return monitorPanel()?.querySelector(".progress-bar")
    }

    function panelErrorMessage() {
      return monitorPanel()?.querySelector('[data-behavior="monitor-error"]')
    }

    function setPanelCompleted(finished) {
      var panel = monitorPanel()?.querySelector('[data-behavior="monitor-completed"]')
      if (!panel) return
      panel.style.display = finished ? "" : "none"
    }

    return this
  }
}
