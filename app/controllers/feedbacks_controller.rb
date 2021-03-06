class FeedbacksController < ApplicationController

  skip_before_action :cannot_access_if_banned
  skip_before_action :cannot_access_without_confirmation
  skip_before_action :ensure_consent_given
  skip_before_action :ensure_user_belongs_to_community
  skip_before_action :set_display_expiration_notice
  # before_action      :can_send_dms, except: [:contact_page, :new, :create]

  FeedbackForm = FormUtils.define_form("Feedback",
                                       :content,
                                       :title,
                                       :url, # referrer
                                       :email
  ).with_validations {
    validates_presence_of :content
  }

  def new
    render_form
  end

  def contact_page
    render_contact_form
  end

  def create
    feedback_form = FeedbackForm.new(params[:feedback])

    unless feedback_form.valid?
      flash[:error] = t("layouts.notifications.feedback_not_saved")
      return render_form(feedback_form)
    end

    return if ensure_not_spam!(params[:feedback], feedback_form)

    author_id = Maybe(@current_user).id.or_else("Anonymous")
    email = current_user_email || feedback_form.email

    feedback = Feedback.create(
      feedback_form.to_hash.merge({
                                    community_id: @current_community.id,
                                    author_id: author_id,
                                    email: email
                                  }))

    MailCarrier.deliver_later(PersonMailer.new_feedback(feedback, @current_community))

    flash[:notice] = t("layouts.notifications.feedback_saved")
    redirect_to search_path
  end

  private

  def can_send_dms
    if @current_community.require_verification_to_send_direct_message? && !(@current_user.present? && @current_user.has_admin_rights?(@current_community))
      if (@current_user.present? && !@current_community_membership.can_send_dms?) || !@current_user.present?
        contact_link = view_context.link_to('please contact Admin to resolve', contact_page_path, target: "_blank")
        flash[:error] = "You are not authorized to send message, #{contact_link}".html_safe
        redirect_to '/s'
      end
    end
  end

  def render_form(form = nil)
    render action: :new, locals: feedback_locals(form).merge({
      has_admin_rights: @current_user && @current_user.has_admin_rights?(@current_community)
    })
  end

    def render_contact_form(form = nil)
    render action: :contact_page, locals: feedback_locals(form).merge({
      has_admin_rights: @current_user && @current_user.has_admin_rights?(@current_community)
    })
  end

  def feedback_locals(feedback_form)
    {
      email_present: current_user_email.present?,
      feedback_form: feedback_form || FeedbackForm.new(title: nil) # title is honeypot
    }
  end

  def current_user_email
    Maybe(@current_user).confirmed_notification_email_to.or_else(nil)
  end

  # Return truthy if is spam
  def ensure_not_spam!(params, feedback_form)
    if spam?(params[:content], params[:title])
      flash[:error] = t("layouts.notifications.feedback_considered_spam")
      return render_form(feedback_form)
    else
      false
    end
  end

  def link_tags?(str)
    str.include?("[url=") || str.include?("<a href=")
  end

  def too_many_urls?(str)
    str.scan("http://").count > 10
  end

  # Detect most usual spam messages
  def spam?(content, honeypot)
    honeypot.present? || link_tags?(content) || too_many_urls?(content)
  end
end
