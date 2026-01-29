;(function () {
  SirTrevor.BlockMixins.Formable = {
    mixinName: "Formable",
    preload: true,

    initializeFormable: function () {
      if (this["afterLoadData"] === undefined) {
        this["afterLoadData"] = function (data) {}
      }
    },

    formId: function (id) {
      return this.blockID + "_" + id
    },

    _serializeData: function () {
      const data = {}
      const formElements = this.inner.querySelectorAll(
        ":input,textarea,select:not(input[type=radio])"
      )

      // Process regular form elements (except radio buttons)
      formElements.forEach(element => {
        if (element.name) {
          // Handle simple case
          data[element.name] = element.value
        }
      })

      // Process checked radio buttons
      const checkedRadios = this.inner.querySelectorAll(
        "input[type=radio]:checked"
      )
      checkedRadios.forEach(radio => {
        const key = radio.dataset.key || radio.getAttribute("name")
        if (!key.match("\\[")) {
          data[key] = radio.value
        }
      })

      // Handle text blocks
      if (this.hasTextBlock()) {
        data.text = this.getTextBlockHTML()
        data.format = "html"
        if (
          data.text &&
          data.text.length > 0 &&
          this.options.convertToMarkdown
        ) {
          data.text = stToMarkdown(data.text, this.type)
          data.format = "markdown"
        }
      }

      return data
    },

    loadData: function (data) {
      if (this.hasTextBlock()) {
        if (
          data.text &&
          data.text.length > 0 &&
          this.options.convertFromMarkdown &&
          data.format !== "html"
        ) {
          this.setTextBlockHTML(SirTrevor.toHTML(data.text, this.type))
        } else {
          this.setTextBlockHTML(data.text)
        }
      }
      this.loadFormDataByKey(data)
      this.afterLoadData(data)
    },

    loadFormDataByKey: function (data) {
      const inputs = this.inner.querySelectorAll(
        ":input:not(button):not([type=hidden])"
      )

      inputs.forEach(input => {
        const key = input.dataset.key || input.getAttribute("name")

        if (key) {
          let processedKey = key
          if (processedKey.match("\\[\\]$")) {
            processedKey = processedKey.replace("[]", "")
          }

          let inputData = data[processedKey]
          if (inputData !== undefined) {
            // Convert to array if not already
            if (!(inputData instanceof Array)) {
              inputData = [inputData]
            }

            // Set value based on input type
            if (input.type === "checkbox" || input.type === "radio") {
              input.checked = inputData.includes(input.value)
            } else {
              input.value = inputData[0] !== undefined ? inputData[0] : ""
            }
          }
        }
      })
    }
  }

  SirTrevor.Block.prototype.availableMixins.push("formable")
})()
