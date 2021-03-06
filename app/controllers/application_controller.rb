class ApplicationController < ActionController::Base
  include Application::CancanStrongParameters

  protect_from_forgery
  after_action -> { expires_now if user_signed_in? }

  def root_redirector
    redirect_to root_path_for_current_user
  end

  def downloads
    file = if (path = params[:path]).present? && !path.match(/\.\./)
             (Rails.root.to_s + path).to_s
           end

    if file && File.exist?(file)
      send_file file, type: 'application/octet-stream'
    else
      head 404
    end
  end

  def user_for_paper_trail
    current_user.try(:id)
  end

  private

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def parameterize_to_date_format(parameters = nil)
    if parameters
      datetime = parameterize_to_datetime_format(parameters)

      { from: datetime[:from].to_date, to: datetime[:to].to_date }
    end
  end

  def parameterize_to_datetime_format(parameters = nil)
    if parameters
      from = Timeliness::Parser.parse(
        parameters[:from], :datetime, zone: :local
      )
      to = Timeliness::Parser.parse(
        parameters[:to], :datetime, zone: :local
      )

      { from: from, to: to }
    end
  end

  def after_sign_in_path_for(resource)
    root_path_for_current_user
  end

  def root_path_for_current_user
    if current_user.blank?
      new_user_session_path
    elsif current_user.shift_auditor?
      operators_path
    else
      movements_path
    end
  end
end
