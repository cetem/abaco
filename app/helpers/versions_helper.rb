module VersionsHelper
  def modificated_warning_if_needed(obj)
    return if obj.created_at == obj.updated_at

    content_tag(
      :span,
      '&#xe025;'.html_safe,
      class: 'iconic text-error',
      title: t('view.versions.have_changes'),
      data: {
        show_tooltip: true
      }
    )
  end
end
