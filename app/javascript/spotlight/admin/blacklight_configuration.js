export default class {
  connect() {
    // Add Select/Deselect all input behavior
    this.addCheckboxToggleBehavior()
    this.addEnableToggleBehavior()
  }

  // Add Select/Deselect all behavior for metadata field names for a given view e.g. Item details.
  addCheckboxToggleBehavior() {
    // Check number of checkboxes against the number of checked
    // checkboxes to determine if all of them are checked or not
    function allCheckboxesChecked(cells) {
      let total = 0
      let checked = 0
      cells.forEach(cell => {
        cell.querySelectorAll("input[type='checkbox']").forEach(cb => {
          total++
          if (cb.checked) {
            checked++
          }
        })
      })
      return total === checked
    }

    // Check or uncheck the "All" checkbox for each view column, e.g. Item details, List, etc.
    function updateSelectAllInput(checkbox, cells) {
      checkbox.checked = allCheckboxesChecked(cells)
    }

    document
      .querySelectorAll("[data-behavior='metadata-select']")
      .forEach(selectCheckbox => {
        const parentCell = selectCheckbox.closest("th")
        if (!parentCell) return

        const table = parentCell.closest("table")
        if (!table) return

        const columnIndex = Array.from(parentCell.parentNode.children).indexOf(
          parentCell
        )
        const columnRows = table.querySelectorAll(
          `tr td:nth-child(${columnIndex + 1})`
        )

        const checkboxes = []
        columnRows.forEach(cell => {
          cell.querySelectorAll("input[type='checkbox']").forEach(cb => {
            checkboxes.push(cb)
          })
        })

        updateSelectAllInput(selectCheckbox, columnRows)

        // Add the check/uncheck behavior to the select/deselect all checkbox
        selectCheckbox.addEventListener("click", () => {
          const allChecked = allCheckboxesChecked(columnRows)
          columnRows.forEach(cell => {
            cell.querySelectorAll("input[type='checkbox']").forEach(cb => {
              cb.checked = !allChecked
              cb.dispatchEvent(new Event("change", { bubbles: true }))
            })
          })
          updateSelectAllInput(selectCheckbox, columnRows)
        })

        // When a single checkbox is selected/unselected, the "All" checkbox should be updated accordingly.
        checkboxes.forEach(cb => {
          cb.addEventListener("change", () => {
            updateSelectAllInput(selectCheckbox, columnRows)
          })
        })
      })
  }

  addEnableToggleBehavior() {
    document
      .querySelectorAll("[data-behavior='enable-feature']")
      .forEach(checkbox => {
        const targetSelector = checkbox.dataset.target
        if (!targetSelector) return
        const target = document.querySelector(targetSelector)
        if (!target) return

        checkbox.addEventListener("change", () => {
          const isChecked = checkbox.checked
          target.querySelectorAll("input[type='checkbox']").forEach(cb => {
            if (!cb.matches("[data-behavior='enable-feature']")) {
              cb.checked = isChecked
              cb.disabled = !isChecked
              cb.dispatchEvent(new Event("change", { bubbles: true }))
            }
          })
        })
      })
  }
}
