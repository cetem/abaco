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

  def pagination_links(objects, options = {})
    other_paginations = params.keys.select { |k| k.to_s.match?(/page$/) }

    options.reverse_merge!(
      params: other_paginations.map { |k| [k, nil] }.to_h,
      theme: 'twitter-bootstrap'
    )

    paginate(objects, options)
  end

  def prehistoric_pagination_links
    fake = OpenStruct.new(
      first?: false,
      last?:  false
    )
    page = (params[:page] || 1).to_i

    next_url = '?page=' + (page + 1).to_s
    prev_url = '?page=' + (page - 1).to_s if page > 1

    content_tag(:div, class: 'pagination') do
      content_tag(:ul) do
        content = []
        content << render(
          'kaminari/twitter-bootstrap/prev_page',
          current_page: fake,
          url: prev_url,
          remote: false
        ) if prev_url

        content << render(
          'kaminari/twitter-bootstrap/next_page',
          current_page: fake,
          url: next_url,
          remote: false
        )
        content.join.html_safe
      end
    end
  end

  def link_to_file(file)
    link_to file.file.filename, downloads_path(path: file.url)
  end

  def get_operator_label_from_id(id)
    RemoteOperator.find(id).try(:label)
  rescue
    'Unknown'
  end

  def t_boolean(value)
    value ? t('label.yes') : t('label.no')
  end
end
