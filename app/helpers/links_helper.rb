module LinksHelper
  def iconic_link(icon, *args)
    options = args.extract_options!

    options['class'] = options['class'].to_s + ' iconic'
    options['title'] ||= 'iconic'
    options['data-show-tooltip'] ||= true

    link_to icon, *args, options
  end

  def link_to_edit(*args)
    options = args.extract_options!

    options['title'] ||= t('label.edit')

    iconic_link '&#x270e;'.html_safe, *args, options
  end

  def link_to_show(*args)
    options = args.extract_options!

    options['class'] ||= 'iconic'
    options['title'] ||= t('label.show')
    options['data-show-tooltip'] = true

    link_to '&#xe074;'.html_safe, *args, options
  end

  def link_to_remove(*args)
    options = args.extract_options!.with_indifferent_access

    options.fetch(:title)

    options['data-confirm'] ||= t('messages.confirmation')

    iconic_link '&#xe05a;'.html_safe, *args, options
  end

  def link_to_destroy(*args)
    options = args.extract_options!.with_indifferent_access

    options['title'] ||= t('label.delete')
    options['method'] ||= :delete
    options['data-confirm'] ||= t('messages.confirmation')

    iconic_link '&#xe05a;'.html_safe, *args, options
  end
end
