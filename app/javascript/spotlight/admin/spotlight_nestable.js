import Sortable from 'sortablejs';

const Module = (function() {
  const nestableContainerSelector = '[data-behavior="nestable"]';
  const sortableOptions = {
    animation: 150,
    draggable: '.dd-item',
    handle: '.dd-handle',
    fallbackOnBody: true,
    swapThreshold: 0.65,
    emptyInsertThreshold: 15,
    onStart: onStartHandler,
    onEnd: onEndHandler,
    onMove: onMoveHandler,
  }
  const draggableClass = 'dd-item';
  const nestedSortableClass = 'dd-list';
  const nestedSortableSelector = '.dd-list';
  const nestedSortableNodeName = 'ol';
  const findNode = (id, container) => container.querySelector(`[data-id="${id}"]`);
  const setWeight = (node, weight) => weightField(node).value = weight;
  const setParent = (node, parentId) => parentPageField(node).value = parentId;
  const weightField = node => findProperty(node, "weight");
  const parentPageField = node => findProperty(node, "parent_page");
  const findProperty = (node, property) => node.querySelector(`input[data-property="${property}"]`);
  let nestedId = 0;

  return {
    init: function(nestedContainers) {
      if (nestedContainers === undefined) {
        nestedContainers = document.querySelectorAll(nestableContainerSelector);
      }

      // nestedContainers could be a jQuery selector result, normalize to an array.
      const containersToInit = Array.from(nestedContainers);
      containersToInit.forEach((container) => {
        // Sir Trevor listens for drag and drop events and will error on Sortable events.
        // Don't let them bubble past the Sortable wrapper.
        container.addEventListener('drop', stopPropagationHandler);
      
        const nestedSortables = [
          ...(container.matches(nestedSortableSelector) ? [container] : []),
          ...Array.from(container.querySelectorAll(nestedSortableSelector))
        ];
        const group = `nested-${nestedId++}`;
        
        nestedSortables.forEach(sortable => {
          new Sortable(sortable, { ...sortableOptions, group: group });
        });
      });
    }
  };

  function stopPropagationHandler(evt) {
    evt.stopPropagation();
  }

  function onStartHandler(evt) {
    makeEmptyChildSortablesForEligibleParents(getNestableContainer(evt.item), getMaxNestingLevelSetting(evt.item));
  }

  function onEndHandler(evt) {
    const nestableContainer = getNestableContainer(evt.item);
    removeEmptySortables(nestableContainer);
    updateWeightsAndRelationships(nestableContainer);
  }

  function onMoveHandler(evt) {
    // The usage of data-max-depth is one off of the standard notion of depth (# edges to root)
    // E.g., data-max-depth=2 allows for one level of nesting.
    // evt.dragged is a draggable in a Sortable (e.g., a dd-item)
    // evt.to is the Sortable to insert into (e.g., a dd-list)
    const maxAllowedDepth = getMaxNestingLevelSetting(evt.to) - 1;
    const newDepth = getSortableDepth(evt.to) + getHeight(evt.dragged);

    // Be careful here. Returning true is different than returning nothing in SortableJS.
    if (newDepth > maxAllowedDepth) {
      return false;
    }
  }

  // Get the depth of the sortable element from the root container
  function getSortableDepth(sortableElement) {
    const originatingGroup = Sortable.get(sortableElement).options.group.name;
    let depth = 0;
    let parentSortableElement = sortableElement;

    while ((parentSortableElement = parentSortableElement.parentElement.closest(nestedSortableSelector))) {
      const parentSortable = Sortable.get(parentSortableElement);
      if (parentSortable?.options.group.name === originatingGroup) {
        depth++;
      }
    }

    return depth;
  }

  // Find the max child depth in the tree, starting from the draggableElement
  function findMaxDepth(draggableElement) {
    const childSortableElement = draggableElement.querySelector(nestedSortableSelector);
    if (!childSortableElement) {
      return 1;
    }

    const children = childSortableElement.querySelectorAll(`.${draggableClass}`);
    const childDepths = Array.from(children).map(findMaxDepth);
    return 1 + Math.max(0, ...childDepths);
  }

  function getHeight(draggableElement) {
    return findMaxDepth(draggableElement) - 1;
  }

  function getNestableContainer(element) {
    return element.closest(nestableContainerSelector);
  }

  function getMaxNestingLevelSetting(element) {
    return getNestableContainer(element).getAttribute('data-max-depth') || 1;
  }

  // Create empty child sortables for all potential parents as appropriate for the given nesting level
  function makeEmptyChildSortablesForEligibleParents(container, nestingLevel) {
    if (nestingLevel <= 1) {
      return;
    }

    const sortableElement = container.querySelector(nestedSortableSelector);
    const sortable = Sortable.get(sortableElement);
    if (!sortable) {
      return;
    }

    const group = sortable.options.group.name;
    const draggableElements = Array.from(sortableElement.children)
      .filter(child => child.classList.contains(draggableClass));

    draggableElements.forEach(draggableElement => {
      if (!draggableElement.querySelector(nestedSortableSelector)) {
        const emptySortableElement = document.createElement(nestedSortableNodeName);
        emptySortableElement.className = nestedSortableClass;
        draggableElement.appendChild(emptySortableElement);
        new Sortable(emptySortableElement, { ...sortableOptions, group: group });
      }
      makeEmptyChildSortablesForEligibleParents(draggableElement, nestingLevel - 1);
    });
  }

  // Remove any empty sortables within the container. They could be empty lists, which are invalid for accessibility.
  function removeEmptySortables(container) {
    const sortableElements = container.querySelectorAll(nestedSortableSelector);
    sortableElements.forEach(sortableElement => {
      if (sortableElement.innerHTML.trim() === '') {
        const sortable = Sortable.get(sortableElement);
        if (sortable) {
          sortable.destroy();
          sortableElement.remove();
        }
      }
    });
  }

  // Traverse all sortables within a container and update the weight and parent_page inputs
  function updateWeightsAndRelationships(container) {
    const sortableElement = container.matches(nestedSortableSelector) ? container : container.querySelector(nestedSortableSelector);
    const nestingLevelSetting = getMaxNestingLevelSetting(sortableElement);
    const sortable = Sortable.get(sortableElement);
    const stack = [{nodes: sortable.toArray(), parentId: ''}];
    let weight = 0;

    while (stack.length > 0) {
      const {nodes, parentId} = stack.pop();

      nodes.forEach((nodeId) => {
        const node = findNode(nodeId, container);
        setWeight(node, weight++);

        if (nestingLevelSetting > 1) {
          setParent(node, parentId);
          const children = node.querySelector(nestedSortableSelector);
          if (children) {
            const sortableElement = Sortable.get(children);
            stack.push({nodes: sortableElement.toArray(), parentId: nodeId});
          }
        }
      });
    }
  }
})();

export default Module
