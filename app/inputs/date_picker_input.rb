class DatePickerInput < SimpleForm::Inputs::Base
  def input
    if object.respond_to?(attribute_name) && object.send(attribute_name)
      value = I18n.l(object.send(attribute_name))
    end
    
    @builder.text_field(
      attribute_name, input_html_options.reverse_merge(default_attributes)
    ).html_safe
  end

  private

  def default_attributes
    {
      value: (I18n.l(object.send(attribute_name)) if object.send(attribute_name)),
      autocomplete: 'off',
      data: { date_picker: true }
    }
  end
end
