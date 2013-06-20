new Rule
  condition: $('#shifts-data').length
  load: ->
    @map.changeTotalAmount ||= ->
      input_val = $(this).val()
      payShiftsLink = $('#pay_shifts_link')

      earn = parseFloat $('span[data-earns]').data('earns')
      credit = parseFloat $('span[data-upfronts]').data('upfronts')
      to_pay = earn + credit

      if  to_pay != input_val
        futureUpfront = (input_val - to_pay).toFixed(2)
        linkHref = payShiftsLink.attr('href')
        updatedUrl = linkHref
          .replace(/upfronts=-?\d+(\.\d{2})?/, "upfronts=#{futureUpfront}")
          .replace(/total_to_pay=-?\d+(\.\d{2})?/, "total_to_pay=#{input_val}")

        payShiftsLink.attr('href', updatedUrl)

    @map.sendPay ||= (e)->
      if e.which == 13
        e.preventDefault()
        $('#pay_shifts_link').click()


    $(document).on 'change keyup', '#to_pay_total', @map.changeTotalAmount
    $(document).on 'keydown', '#to_pay_total', @map.sendPay

  unload: ->
    $(document).off 'change keyup', '#to_pay_total', @map.changeTotalAmount
