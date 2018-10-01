class DatetimePickerInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    if object.respond_to?(attribute_name) && object.send(attribute_name).present?
      value = I18n.l(
        Time.parse(object.send(attribute_name).to_s), format: :minimal
      )
    end

    @builder.text_field(
      attribute_name,
      merge_wrapper_options(
        input_html_options.reverse_merge(
          value: value,
          autocomplete: 'off',
          data: { 'datetime-picker' => true }
        ),
        wrapper_options
      )
    ).html_safe
  end
end
