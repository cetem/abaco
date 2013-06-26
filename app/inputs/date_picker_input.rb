class DatePickerInput < SimpleForm::Inputs::Base
  def input
    if object.respond_to?(attribute_name) && object.send(attribute_name)
      value = I18n.l(object.send(attribute_name))
    end
    
    @builder.text_field(
<<<<<<< HEAD
      attribute_name,
      input_html_options.reverse_merge(
        value: value,
        autocomplete: 'off',
        data: { 'date-picker' => true }
      )
=======
      attribute_name, input_html_options.reverse_merge(default_attributes)
>>>>>>> adc69e9859c788ca16d5fe1ec43a2896703456c5
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
