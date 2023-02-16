Spotlight.onLoad(function(){
  $('.zpr-link').on('click', function() {
    var modalDialog = $('#blacklight-modal .modal-dialog');
    var modalContent = modalDialog.find('.modal-content')
    modalDialog.removeClass('modal-lg')
    modalDialog.addClass('modal-xl')
    modalContent.html('<div id="osd-modal-container"></div>');
    var controls = `<div class="controls d-flex justify-content-center justify-content-md-end">
        <div class="custom-close-controls pr-3 pt-3">
          <button type="button" class="btn btn-dark" data-dismiss="modal" aria-hidden="true">${Spotlight.ZprLinks.close}</button>
        </div>
        <div class="zoom-controls mb-3 mr-md-3">
          <button id="osd-zoom-in" type="button" class="btn btn-dark">${Spotlight.ZprLinks.zoomIn}</button>
          <button id="osd-zoom-out" type="button" class="btn btn-dark">${Spotlight.ZprLinks.zoomOut}</button>
        </div>
        <div id="empty-div-required-by-osd"></div>
      </div>`

    $('#osd-modal-container').append('<div id="osd-div"></div>');
    $('#osd-modal-container').append(controls);

    $('#blacklight-modal').modal('show');
    
    $('#blacklight-modal').one('hidden.bs.modal', function (event) {
      modalDialog.removeClass('modal-xl')
      modalDialog.addClass('modal-lg')
    });

    OpenSeadragon({
      id: 'osd-div',
      zoomInButton: "osd-zoom-in",
      zoomOutButton: "osd-zoom-out",
      // This is a hack where OpenSeadragon (if using mapped buttons) requires you
      // to map all of the buttons.
      homeButton: "empty-div-required-by-osd",
      fullPageButton: "empty-div-required-by-osd",
      nextButton: "empty-div-required-by-osd",
      previousButton: "empty-div-required-by-osd",
      tileSources: [$(this).data('iiif-tilesource')]
    })
  });
});
