//= require_tree ../templates/amazon_assets

/*
 *  Добавление и удаление файлов
 *
 */

app.modules.attachmentsFields = (function(self) {
  var 
    _validFormat, 
    _validSize,
    SELECTORS = {
      $block: '.js-attachments-fields'
    };

  function _toggleFileValidationMessage(file, $block) {
    // допускаем, что файлы могут быть валидны при отсутствующем размере
    // поэтому сообщения об ошибке выводим в случае, если точно знаем, что размер невалиден
    $block
      .find('.js-error-message-format').toggleClass('dn', !file || _validFormat).end()
      .find('.js-error-message-size').toggleClass('dn', !file || !file.size || _validSize);
  }

  function _getFileSize(fileSize, unitsOfMeasure) {
    return Math.round((fileSize < FileAPI.KB ? fileSize :
      (fileSize / (fileSize > FileAPI.MB ? FileAPI.MB : FileAPI.KB))) * 2) / 2 +
      unitsOfMeasure[fileSize < FileAPI.KB ? 'byte' : fileSize > FileAPI.MB ? 'MB' : 'KB'];
  }

  function _renderAttachedFile(data, $block) {
    $block.find('.js-attached-files').append(HandlebarsTemplates['amazon_assets/attached_file'](data));
  }

  function _getFieldName(type, index, nameTemplate) {
    return nameTemplate.replace('%index%', index).replace('%type%', type);
  }

  function _renderAttachedFiles(files, $block) {
    var data = $block.data();

    $.each(files, function(index, originalFile) {
      _renderAttachedFile({
        name: originalFile['origin_file_name'],
        ext: _getFileExtension(originalFile['origin_file_name']).toLowerCase(),
        fullSize: _getFileSize(originalFile['local_file_size'], data.unitsOfMeasure),
        id: originalFile.id,
        type: originalFile['local_content_type'],
        idFieldName: _getFieldName('id', index, data.nameTemplate),
        destroyFieldName: _getFieldName('_destroy', index, data.nameTemplate),
        fileFieldName: _getFieldName('local', index, data.nameTemplate),
        index: index
      },
      $block);
    });
  }

  function _getFileExtension(fileName) {
    return fileName.split('.').pop();
  }

  function _filterFile(file, $block) {
    var 
      data = $block.data(),
      permittedTypes = data.permittedTypes;
    
    _validFormat = permittedTypes ? new RegExp(permittedTypes.join('|').toLowerCase()).test(file.type.toLowerCase()) :
      true;
    _validSize = file.size < data.maxSize * FileAPI.MB;

    // допускаем, что файл может быть валиден,
    // если по тем или иным причинам узнать размер файла нет возможности
    return _validFormat && (!file.size || _validSize);
  }

  function _disableOrEnableButton($block) {
    $block.find('.js-attach-file')
      .toggleClass('disabled', $block.find('.js-file-item:visible').length === $block.data('max-count'));
  }

  function _renewFileInput($fileInput, index) {
    $fileInput.after(
      $fileInput.clone(true).attr({ 
        name: _getFieldName('local', index, $fileInput.closest('.js-attachments-fields').data('name-template'))
      }).val('')
    ).hide();
  }

  function _prepareDataBeforeRendering(file, $block) {
    var data = $block.data();

    file.index = $block.find('.js-file-item').length || 0;
    file.ext = _getFileExtension(file.name).toLowerCase();
    file.fullSize = file.size && _getFileSize(file.size, data.unitsOfMeasure);
    file.fileFieldName = _getFieldName('local', file.index, data.nameTemplate);

    return file;
  }

  function _detachFile($detachLink, $block) {
    $detachLink.closest('.js-file-item').hide().find('[type="hidden"]').prop({disabled: false});
    $block.find('[name="' + $detachLink.data('file-field-name') + '"]').prop({disabled: true});
  }

  function _validateComponent(isValid, $block) {
    if ($block.is('[data-required]')) {
      $block.find('.js-file-item:visible').length ? isValid.resolve() : isValid.reject();
    } else {
      isValid.resolve();
    }

    return isValid;
  }

  function _toggleRequiredFieldValidationMessage(display, $block) {
    $block.find('.js-error-message-required-field').toggleClass('dn', !display);
  }

  function _fileApiInit($button) {
    FileAPI.event.on($button, 'change', function (event) {
      var
        file = FileAPI.getFiles(event),
        $fileInput = $(event.target),
        $block = $fileInput.closest('.js-attachments-fields');

      _toggleFileValidationMessage(null, $block);
      FileAPI.filterFiles(
        file, 
        function (file) { 
          return _filterFile(file, $block) 
        },
        function (file, rejectedFile) {
          if (file.length) {
            var data = _prepareDataBeforeRendering(file[0], $block);

            _renderAttachedFile(data, $block);
            _renewFileInput($fileInput, ++data.index);
            $doc.trigger('attachFile:attachAndDetachFile', [$fileInput]);
            _toggleRequiredFieldValidationMessage(false, $block);
          } else {
            _toggleFileValidationMessage(rejectedFile.length ? rejectedFile[0] : {}, $block);
            $fileInput.val('');
            $doc.trigger('error:attachAndDetachFile');
          }
          _disableOrEnableButton($block);
        }
      );
    });
  }

  function _listener() {
    $doc
      .on('click', '.js-detach-file', function() {
        var 
          $this = $(this),
          $block = $this.closest('.js-attachments-fields');

        _detachFile($this, $block);
        _disableOrEnableButton($block);
        _toggleFileValidationMessage(null, $block);
        $doc.trigger('detachFile:attachAndDetachFile', [$this]);
      })
      .on('validateComponent:attachmentsFields', function(event, isValid) {
        var $block = event.target.closest('.js-attachments-fields');
        _validateComponent(isValid, $block)
          .done(function () { _toggleRequiredFieldValidationMessage(false, $block); })
          .fail(function () { _toggleRequiredFieldValidationMessage(true, $block); });
      })
      .on('click', '.js-attach-file-button', function() {
        $doc.trigger('browseFiles:attachAndDetachFile', [$(this)]);
      });
  }

  function _init() {
    $('.js-attachments-fields').not('.js-attachments-fields-inited').each(function () {
      $(this).addClass('js-attachments-fields-inited');
      var attachedFiles = $(this).data('attached-files');

      _fileApiInit($(this).find('.js-attach-file-button')[0]);
      attachedFiles && _renderAttachedFiles(attachedFiles, $(this));
    });
  }

  self.load = function() {
    _init();
    _listener();
  };

  $.extend(self, {
    initAttachment: _init
  });

  return self;
})(app.modules.attachmentsFields || {});
