$(document).on 'click', 'select[readonly="readonly"]', (e) ->
  e.preventDefault()
  e.stopPropagation()
