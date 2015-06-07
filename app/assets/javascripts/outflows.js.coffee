
new Rule
  condition: $('#shifts-data').length
  load: ->
    @map.changeTotalAmount ||= ->
      row = $(this).parents('tr:first')
      payShiftsLink = row.find('a[data-pay-shifts-button]')

      input_val = parseFloat row.find('[data-to-pay-total]').val()
      with_incentive = row.find('[data-with-incentive]').data('with-incentive')
      earn = parseFloat row.find('span[data-earns]').data('earns')
      credit = parseFloat row.find('span[data-upfronts]').data('upfronts')
      to_pay = parseFloat (earn + credit).toFixed(2)

      futureUpfront = (input_val - to_pay).toFixed(2)
      linkHref = payShiftsLink.data('replaceable-link')
      updatedUrl = linkHref
        .replace(/UPFRONTS/, futureUpfront)
        .replace(/AMOUNT/, input_val)
        .replace(/INCENTIVE/, with_incentive)

      payShiftsLink.attr('href', updatedUrl)

    @map.sendPay ||= (e)->
      if e.which == 13
        e.preventDefault()
        $(this).parents('tr:first').find('a[data-pay-shifts-button]').click()

    @map.changeIncentive ||= ->
      value = this.checked
      row = $(this).parents('tr:first')

      row.find('[data-with-incentive]').data('with-incentive', value)
      row.find('[data-to-pay-total]').trigger('change')

    $(document).on 'change keyup', '[data-to-pay-total]', @map.changeTotalAmount
    $(document).on 'keydown', '[data-to-pay-total]', @map.sendPay
    $(document).on 'change click', '[data-with-incentive]', @map.changeIncentive

  unload: ->
    $(document).off 'change keyup', '[data-to-pay-total]', @map.changeTotalAmount
    $(document).off 'change click', '[data-with-incentive]', @map.changeIncentive
