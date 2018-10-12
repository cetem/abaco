jQuery ($)->
  $(document).on 'change', 'input.autocomplete-field', ->
    if /^\s*$/.test($(this).val())
      $(this).next('input.autocomplete-id:first').val('')

  $(document).on 'click', '.clean-autocomplete', (e)->
    e.stopPropagation()
    e.preventDefault()

    target = $(e.currentTarget).data('target')

    input = $("[data-autocomplete-id-target='#{target}']")
    target = $(target)

    target.val('')
    input.val('')
    input.removeAttr('readonly')
    input.removeAttr('disabled')

  $(document).on 'focus', 'input.autocomplete-field:not([data-observed])', ->
    input = $(this)

    input.autocomplete
      source: (request, response)->
        $.ajax
          url: input.data('autocompleteUrl')
          dataType: 'json'
          data: { q: request.term }
          success: (data)->
            response $.map data, (item)->
              content = $('<div></div>')

              content.append $('<span class="title"></span>').text(item.label)

              { label: content.html(), value: item.label, item: item }
      type: 'get'
      select: (event, ui)->
        selected = ui.item

        input.val(selected.value)
        input.data('item', selected.item)
        $(input.data('autocompleteIdTarget')).val(selected.item.id)

        if selected.item.admin
          $(input.data('autocompleteAdminTarget')).val(selected.item.admin)

        if selected.item.label
          input.data('autocomplete-label', selected.item.label)

        if input.data('autocompleteReadonly')
          input.attr('readonly', 'readonly')

        input.trigger 'autocomplete:update', input

        false
      open: -> $('.ui-menu').css('width', input.width())

    input.data('ui-autocomplete')._renderItem = (ul, item)->
      $('<li></li>').data('item.autocomplete', item).append(
        $('<a></a>').html(item.label)
      ).appendTo(ul)
  .attr('data-observed', true)

  $(document).on 'focusout blur', '.create-without-autocomplete:not([readonly])', (e)->
    input = $(e.currentTarget)
    target = $(input.data('autocompleteIdTarget'))

    if input.val().length == 0 || target.val().length
      return

    swal(
      title: input.data('swalTitle')
      text: input.data('swalText')
      type: 'warning'
      reverseButtons: true
      showCancelButton: true
      cancelButtonText: input.data('swalCancel')
      confirmButtonText: input.data('swalConfirm')
    ).then (result) ->
      if result.value
        data = {}
        data[input.data('createAssociationMainKey')] = {}
        data[input.data('createAssociationMainKey')][input.data('createAssociationField')] = input.val()

        $.ajax
          url: input.data('createAssociationUrl')
          data: data
          type: 'POST'
          dataType: 'json'
          success: (result)->
            debugger
            if result.errors
              swal(
                text: result.errors
                type: 'error'
                confirmButtonText: 'Ok'
              )
            else
              target.val(result.id)
              input.attr('readonly', 'readonly')
              swal.close()
          error: ->
            swal(
              text: input.data('swalErrorMsg')
              type: 'error'
              confirmButtonText: 'Ok'
            )
      else
        input.val('')
        target.val('')
