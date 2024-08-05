import TomSelect from 'tom-select';

export default class {
  connect() {
    const tagOptions = {
      closeAfterSelect: true,
      create: true,
      createOnBlur: true,
      duplicates: false,
      hideSelected: true,
      labelField: 'name',
      loadThrottle: 300,
      maxOptions: 100,
      persist: false,
      plugins: ['remove_button'],
      preload: true,
      searchField: 'name',
      valueField: 'name',
      onItemAdd: function(value, item) {
        this.control_input.value = '';
      },
      load: function(query, callback) {
        fetch(this.input.dataset.autocompleteUrl)
          .then(response => response.json())
          .then(json => {
            callback(json.map(tag => ({name: tag.trim()})));
          }).catch(() => callback());
      }
    }

    document.querySelectorAll('[data-autocomplete-tag="true"]').forEach(tagElement => {
      // Handle leading spaces (e.g., 'Tag 1, Tag 2') or else the user can add what appear to be duplicate tags.
      const items = tagElement.value.split(',').map(item => item.trim()).filter(Boolean);
      const options = items.map(item => ({name: item}));
      new TomSelect(tagElement, { ...tagOptions, items, options });
    });
  }
}
