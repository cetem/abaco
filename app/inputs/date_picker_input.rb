class DatePickerInput < SimpleForm::Inputs::Base
  def input
    @builder.text_field(
      attribute_name, input_html_options.reverse_merge(default_attributes)
    ).html_safe
  end

  private

  def default_attributes
    value = if object && object.send(attribute_name)
              object.send(attribute_name)
            else
              Date.today
            end

    {
      value: I18n.l(value),
      autocomplete: 'off',
      data: { date_picker: true }
    }
  end
end
