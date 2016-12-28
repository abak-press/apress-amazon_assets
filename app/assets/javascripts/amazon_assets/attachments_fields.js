//= require_tree ../templates/amazon_assets

/*
 *  Добавление и удаление файлов
 *
 */

app.modules.attachmentsFields = (function(self) {
  var _$rootEl, _validFormat, _validSize;

  function _toggleFileValidationMessage(file) {
    // допускаем, что файлы могут быть валидны при отсутствующих типе и/или размере
    // поэтому сообщения об ошибке выводим в случае, если точно знаем, что формат и/или размер невалидны
    _$rootEl
      .find('.js-error-message-format').toggleClass('dn', !file || !file.type || _validFormat).end()
      .find('.js-error-message-size').toggleClass('dn', !file || !file.size || _validSize);
  }

  function _getFileSize(fileSize) {
    return Math.round((fileSize < FileAPI.KB ? fileSize :
      (fileSize / (fileSize > FileAPI.MB ? FileAPI.MB : FileAPI.KB))) * 2) / 2 +
        _$rootEl.data('units-of-measure')[fileSize < FileAPI.KB ? 'byte' : fileSize > FileAPI.MB ? 'MB' : 'KB'];
  }

  function _renderAttachedFile(data) {
    _$rootEl.find('.js-attached-files').append(HandlebarsTemplates['amazon_assets/attached_file'](data));
  }

  function _getFieldName(type, index) {
    return _$rootEl.data('name-template').replace('%index%', index).replace('%type%', type);
  }

  function _renderAttachedFiles(files) {
    $.each(files, function(index, originalFile) {
      _renderAttachedFile({
        name: originalFile['origin_file_name'],
        ext: _getFileExtension(originalFile['origin_file_name']).toLowerCase(),
        fullSize: _getFileSize(originalFile['local_file_size']),
        id: originalFile.id,
        type: originalFile['local_content_type'],
        idFieldName: _getFieldName('id', index),
        destroyFieldName: _getFieldName('_destroy', index),
        fileFieldName: _getFieldName('local', index),
        index: index
      });
    });
  }

  function _getFileExtension(fileName) {
    return fileName.split('.').pop();
  }

  function _filterFile(file) {
    var permittedTypes = _$rootEl.data('permitted-types');

    _validFormat = permittedTypes ? new RegExp(permittedTypes.join('|').toLowerCase()).test(file.type.toLowerCase()) :
      true;
    _validSize = file.size < _$rootEl.data('max-size') * FileAPI.MB;

    // допускаем, что файл может быть валиден,
    // если по тем или иным причинам узнать тип или размер файла нет возможности
    return (!file.type || _validFormat) && (!file.size || _validSize);
  }

  function _disableOrEnableButton() {
    _$rootEl.find('.js-attach-file')
      .toggleClass('disabled', _$rootEl.find('.js-file-item:visible').length === _$rootEl.data('max-count'));
  }

  function _renewFileInput($fileInput, index) {
    $fileInput.after(
      $fileInput.clone(true).attr({name: _getFieldName('local', index)}).val('')
    ).hide();
  }

  function _prepareDataBeforeRendering(file) {
    file.index = _$rootEl.find('.js-file-item').length || 0;
    file.ext = _getFileExtension(file.name).toLowerCase();
    file.fullSize = file.size && _getFileSize(file.size);
    file.fileFieldName = _getFieldName('local', file.index);

    return file;
  }

  function _detachFile($detachLink) {
    $detachLink.closest('.js-file-item').hide().find('[type="hidden"]').prop({disabled: false});
    _$rootEl.find('[name="' + $detachLink.data('file-field-name') + '"]').prop({disabled: true});
  }

  function _validateComponent(isValid) {
    if (_$rootEl.is('[data-required]')) {
      _$rootEl.find('.js-file-item:visible').length ? isValid.resolve() : isValid.reject();
    } else {
      isValid.resolve();
    }

    return isValid;
  }

  function _toggleRequiredFieldValidationMessage(display) {
    _$rootEl.find('.js-error-message-required-field').toggleClass('dn', !display);
  }

  function _listener() {
    FileAPI.event.on(_$rootEl.find('.js-attach-file-button')[0], 'change', function(event) {
      var
        file = FileAPI.getFiles(event),
        $fileInput = $(event.target);

      _toggleFileValidationMessage();
      FileAPI.filterFiles(file, _filterFile, function(file, rejectedFile) {
        if (file.length) {
          var data = _prepareDataBeforeRendering(file[0]);

          _renderAttachedFile(data);
          _renewFileInput($fileInput, ++data.index);
          $doc.trigger('attachFile:attachAndDetachFile', [$fileInput]);
          _toggleRequiredFieldValidationMessage();
        } else {
          _toggleFileValidationMessage(rejectedFile.length ? rejectedFile[0] : {});
          $fileInput.val('');
          $doc.trigger('error:attachAndDetachFile');
        }
        _disableOrEnableButton();
      });
    });

    _$rootEl
      .on('click', '.js-detach-file', function() {
        var $this = $(this);

        _detachFile($this);
        _disableOrEnableButton();
        _toggleFileValidationMessage();
        $doc.trigger('detachFile:attachAndDetachFile', [$this]);
      })
      .on('validateComponent:attachmentsFields', function(event, isValid) {
        _validateComponent(isValid)
          .done(function() { _toggleRequiredFieldValidationMessage(false); })
          .fail(function() { _toggleRequiredFieldValidationMessage(true); });
      });
  }

  self.load = function() {
    _$rootEl = $('.js-attachments-fields');
    var attachedFiles = _$rootEl.data('attached-files');

    attachedFiles && _renderAttachedFiles(attachedFiles);
    _listener();
  };

  return self;
})(app.modules.attachmentsFields || {});
