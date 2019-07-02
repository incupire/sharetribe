class AvontageVouchersController < ApplicationController

	before_action do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_accept_or_reject")
  end

  before_action :fetch_transaction

 	before_action :ensure_is_starter


	def voucher_show
		custom_field = CustomFieldName.find_by(value: 'INSTRUCTIONS (enter redeem instructions, any restrictions, or other details the Buyer needs to be aware)')
    if custom_field.present? && @transaction.listing.answer_for(custom_field)
      @instructions = @transaction.listing.answer_for(custom_field).display_value
    else
      @instructions = nil
    end
    voucher_name = "voucher_#{@transaction.id}"
    respond_to do |format|
      format.html
      format.pdf do
        @pdf = render_to_string(pdf: voucher_name, default_header: false, template: "avontage_vouchers/voucher.html.erb", :locals => {transaction: @transaction, instructions: @instructions})
        send_data(@pdf, :filename => voucher_name, :type=>"application/pdf", disposition: "inline")
      end
    end
	end

	private

	def ensure_is_starter
    unless @transaction.starter == @current_user
      flash[:error] = "You are not authorised to see this page"
      redirect_to search_path
    end
  end

  def fetch_transaction
  	@transaction ||= Transaction.find(params[:id])
    @community ||= Community.find(@transaction.community_id)
  end

end
