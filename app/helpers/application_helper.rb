module ApplicationHelper
  def title
    [t('app_name'), @title].compact.join(' | ')
  end

  def show_menu_link(options = {})
    name = t("menu.#{options[:name]}")
    classes = []

    classes << 'active' if [*options[:controllers]].include?(controller_name)

    content_tag(
      :li, link_to(name, options[:path]),
      class: (classes.empty? ? nil : classes.join(' '))
    )
  end

  def show_button_dropdown(main_action, extra_actions = [], options = {})
    if extra_actions.blank?
      main_action
    else
      out = ''.html_safe

      out << render(
        partial: 'shared/button_dropdown', locals: {
          main_action: main_action, extra_actions: extra_actions
        }
      )
    end
  end

  def pagination_links(objects, param_name = 'page', params = nil)
    pagination_links = will_paginate objects, param_name: param_name,
      inner_window: 1, outer_window: 1, params: params,
      renderer: BootstrapPaginationHelper::LinkRenderer,
      class: 'pagination pagination-right'
    page_entries = content_tag(
      :blockquote,
      content_tag(
        :small,
        page_entries_info(objects),
        class: 'page-entries hidden-desktop pull-right'
      )
    )

    pagination_links ||= empty_pagination_links

    content_tag :div, pagination_links + page_entries, class: 'pagination-container'
  end

  def empty_pagination_links
    previous_tag = content_tag(
      :li,
      content_tag(:a, t('will_paginate.previous_label').html_safe),
      class: 'previous_page disabled'
    )
    next_tag = content_tag(
      :li,
      content_tag(:a, t('will_paginate.next_label').html_safe),
      class: 'next disabled'
    )

    content_tag(
      :div,
      content_tag(:ul, previous_tag + next_tag),
      class: 'pagination pagination-right'
    )
  end

  def prehistoric_pagination_links
    current_page = params[:page].to_i.zero? ? 1 : params[:page].to_i

    next_class = "next #{'disabled' if @paginate_size < 10}"
    next_link = content_tag(:li, link_to(
      raw(t('will_paginate.next_label')),
      "#{request.path}?page=#{current_page + 1}",
      class: next_class
    ), class: next_class)

    prev_page = (current_page > 1) ? (current_page - 1) : 1
    prev_class = "previous_page #{'disabled' if current_page == 1}"
    prev_link = content_tag(:li, link_to(
      raw(t('will_paginate.previous_label')),
      "#{request.path}?page=#{prev_page}",
      class: prev_class
    ), class: prev_class)

    ul = content_tag(:ul, prev_link + next_link)
    div_pag = content_tag(:div, ul, class: 'pagination pagination-right')

    content_tag(:div, div_pag, class: 'pagination-container')
  end

  def link_to_file(file)
    link_to file.file.filename, downloads_path(path: file.url)
  end

  def get_operator_label_from_id(id)
    Operator.find(id).try(:label)
  rescue
    'Unknown'
  end
end
